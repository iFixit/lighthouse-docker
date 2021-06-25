import { LighthouseReport, getUrl } from "./Lighthouse";
import { DateTime } from "luxon";
import { sortBy } from "lodash";

export interface Differential {
  current: LighthouseReport;
  previous: LighthouseReport;
  section: string;
  page: string;
  current_url: string;
  previous_url: string | null;
  current_html_url: string;
}

export function getParam(name) {
  // See demo in https://developer.mozilla.org/en-US/docs/Web/API/URL/searchParams
  const url = new URL(window.location.href as string);
  return url.searchParams.get(name);
}

export async function getData(
  previous_param: null | string,
  current_param: null | string
): Promise<Differential[]> {
  const index = await dataFetch("index.json");

  const parsed: Record[] = sortBy(index.map(parseRecordDate), (r) =>
    r.date.toMillis()
  );

  if (parsed.length === 0) {
    throw new Error("No records");
  }

  const current_record = current_param
    ? selectRecord(current_param, parsed)
    : parsed[parsed.length - 1];

  if (!current_record) {
    throw new InvalidSelectorError("Current record selector invalid");
  }

  const previous_record = choosePreviousRecord(
    previous_param,
    current_record,
    parsed
  );

  if (!previous_record) {
    throw new InvalidSelectorError("Previous record selector invalid");
  }

  const current = await getFromRecord(current_record);
  const previous = await getFromRecord(previous_record);

  const pairs = indexesToDifferentials(previous, current);
  return await Promise.all(pairs);
}

interface Record {
  date: DateTime;
  path: string;
}

interface IndexReport {
  data: any;
  date: DateTime;
  path: string;
}

async function dataFetch(path) {
  const url = getUrl(path);
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Fetch failed: ${response.status}`);
  }
  return response.json();
}

function parseRecordDate(record): Record {
  return {
    path: record.path,
    date: DateTime.fromISO(record.date),
  };
}

function selectRecord(param: string, records: Record[]): Record | null {
  const re = new RegExp(param);
  const matches = records.filter((r) => re.test(r.path));
  if (matches.length > 0) {
    return matches[matches.length - 1];
  }
  return null;
}

function choosePreviousRecord(
  param: string | null,
  current: Record,
  records: Record[]
): Record | null {
  if (param) {
    return selectRecord(param, records);
  }
  const old_records = records.filter(
    (r) => r.date < current.date.minus({ days: 7 })
  );
  // If we don't have an old enough record, use the oldest thing we do have.
  return old_records.length > 0
    ? old_records[old_records.length - 1]
    : records[0];
}

async function getFromRecord(record: Record): Promise<IndexReport> {
  const path = record.path + "/";
  const data = await dataFetch(path + "index.json");
  return {
    data,
    date: record.date,
    path: path,
  };
}

function indexesToDifferentials(
  previous: IndexReport,
  current: IndexReport
): Array<Promise<Differential>> {
  const current_data: { [key: string]: string[] } = current.data;
  return Object.entries(current_data)
    .flatMap(([key, values]) =>
      values.map((value) => {
        console.log(previous, current);
        const path = `${key}/${value}.report.json`;
        return {
          section: key,
          page: value,
          current: current.path + path,
          previous: previous.data[key]?.includes(value)
            ? previous.path + path
            : null,
        };
      })
    )
    .map(async ({ current, previous, section, page }) => {
      const current_data = await dataFetch(current);
      const previous_data = previous ? await dataFetch(previous) : null;
      return {
        current: current_data,
        previous: previous_data,
        section,
        page,
        current_url: current,
        current_html_url: current.replace(/\.json$/, ".html"),
        previous_url: previous,
      };
    });
}

export class InvalidSelectorError extends Error {}
