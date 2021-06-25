import React from "react";
import Container from "@material-ui/core/Container";
import Table from "@material-ui/core/Table";
import TableBody from "@material-ui/core/TableBody";
import TableCell from "@material-ui/core/TableCell";
import TableHead from "@material-ui/core/TableHead";
import TableRow from "@material-ui/core/TableRow";
import { sortBy } from "lodash";
import styled from "@emotion/styled";
import { DateTime } from "luxon";

import { RenderInterface, ReportSequenceInterface } from "./render";
import { SectionLink, Score, findMin } from "./helpers";
import { Differential } from "./data_fetch";
import { getUrl } from "./Lighthouse";

const ScoreTableHeader = styled.h2`
  margin-top: 100px;
`;

export function StatusReport({ data }: RenderInterface) {
  const name_mapping = new Map([
    ["first-contentful-paint", 15],
    ["speed-index", 15],
    ["largest-contentful-paint", 25],
    ["interactive", 15],
    ["total-blocking-time", 25],
    ["cumulative-layout-shift", 5],
  ]);
  const nameList: string[] = Array.from(name_mapping.keys());
  const names = sortBy(nameList, (k) => -(name_mapping.get(k) || 0));
  const record = data[0];
  const previous_time = DateTime.fromISO(record.previous.fetchTime).toRFC2822();
  const current_time = DateTime.fromISO(record.current.fetchTime).toRFC2822();
  return (
    <Container>
      <h1>Report view</h1>
      <div>
        ({previous_time} vs. {current_time})
      </div>
      <ReportTable data={data} names={names} />
      <ScoreTableHeader>Worst overall scores</ScoreTableHeader>
      <WorstEntries
        names={names}
        data={data}
        extract={(d) => d.current.categories.performance.score}
      />
      {names.map((name) => {
        const extract = (d) => d.current.audits[name]?.score;
        return (
          <React.Fragment>
            <ScoreTableHeader>
              Worst {name} scores ({name_mapping.get(name)}%)
            </ScoreTableHeader>
            <WorstEntries
              names={names}
              data={data}
              extract={extract}
              key={name}
            />
          </React.Fragment>
        );
      })}
    </Container>
  );
}

function ReportTable({ data, names }: ReportSequenceInterface) {
  return (
    <Table stickyHeader size="small">
      <TableHead>
        <TableRow>
          <TableCell>Page</TableCell>
          <TableCell>Overall Score</TableCell>
          {names.map((k) => {
            return <TableCell key={k}>{k}</TableCell>;
          })}
          <TableCell>Worst performer</TableCell>
        </TableRow>
      </TableHead>
      <TableBody>
        {data.map((row: Differential) => (
          <TableRow key={row.section + row.page}>
            <TableCell>
              <a
                href={getUrl(row.current_html_url)}
              >{`${row.section}: ${row.page}`}</a>
            </TableCell>
            <TableCell>
              <Score
                previous={row.previous?.categories.performance.score * 100}
                current={row.current.categories.performance.score * 100}
              />
            </TableCell>
            {names.map((k) => {
              const current = row.current.audits[k];
              if (!current) {
                return <TableCell key={k} />;
              }
              const previous_score = row.previous
                ? row.previous.audits[k]?.score * 100
                : undefined;
              return (
                <TableCell key={k}>
                  <SectionLink diff={row}>
                    <Score
                      previous={previous_score}
                      current={current.score * 100}
                    />
                  </SectionLink>
                </TableCell>
              );
            })}
            <TableCell>{findMin(names, row)}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}

function WorstEntries({
  names,
  data,
  extract,
}: {
  names: string[];
  data: Differential[];
  extract: (Differential) => any;
}) {
  const limited_data = sortBy(data, extract).slice(0, 5);
  return <ReportTable names={names} data={limited_data} />;
}
