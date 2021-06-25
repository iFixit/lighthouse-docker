import React from "react";
import Container from "@material-ui/core/Container";
import Table from "@material-ui/core/Table";
import TableBody from "@material-ui/core/TableBody";
import TableCell from "@material-ui/core/TableCell";
import TableHead from "@material-ui/core/TableHead";
import TableRow from "@material-ui/core/TableRow";
import styled from "@emotion/styled";
import { DateTime } from "luxon";

import { RenderInterface, ReportSequenceInterface } from "./render";
import { SectionLink, Score, findMin } from "./helpers";
import { Differential } from "./data_fetch";
import { getUrl } from "./Lighthouse";
import { diffColor } from "./colors";

const DiffDisplay = styled.a`
  display: inline-block;
  width: 50px;
  height: 50px;
  font-size: 10px;
  background-image: ${(props) => props.color};
  text-decoration: none;
  display: flex;
  flex-wrap: wrap;
  align-content: center;
  justify-content: center;
  color: black;
`;

export function DiffReport({ data }: RenderInterface) {
  const names = [
    "first-contentful-paint",
    "speed-index",
    "largest-contentful-paint",
    "interactive",
    "total-blocking-time",
    "cumulative-layout-shift",
  ];
  const record = data[0];
  const previous_time = DateTime.fromISO(record.previous.fetchTime).toRFC2822();
  const current_time = DateTime.fromISO(record.current.fetchTime).toRFC2822();
  return (
    <Container>
      <h1>Diff view</h1>
      <div>
        ({previous_time} vs. {current_time})
      </div>
      <DiffTable data={data} names={names} />
    </Container>
  );
}

interface DiffRecord {
  previous: number;
  current: number;
  url: string;
}

function DiffTable({ data, names }: ReportSequenceInterface) {
  return (
    <Table stickyHeader size="small">
      <TableHead>
        <TableRow>
          <TableCell>Page</TableCell>
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
            {names.map((k) => {
              const current = row.current.audits[k];
              if (!current) {
                return <TableCell key={k} />;
              }
              const previous = row.previous?.audits?.[k];
              if (!previous) {
                return (
                  <SectionLink diff={row}>
                    <TableCell key={k}>
                      <Score current={current} />
                    </TableCell>
                  </SectionLink>
                );
              }
              return (
                <TableCell key={k}>
                  <DiffScore
                    previous={previous.score * 100}
                    current={current.score * 100}
                    url={row.current_html_url}
                  />
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

function DiffScore({ previous, current, url }: DiffRecord) {
  const color = diffColor(current - previous);
  return (
    <DiffDisplay href={getUrl(url) + "#performance"} color={color}>
      {Math.round(current - previous)}
    </DiffDisplay>
  );
}
