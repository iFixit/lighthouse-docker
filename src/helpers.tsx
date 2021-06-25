import React from "react";
import Tooltip from "@material-ui/core/Tooltip";
import HelpOutline from "@material-ui/icons/HelpOutline";
import styled from "@emotion/styled";
import { sortBy } from "lodash";

import { Differential } from "./data_fetch";
import { getUrl } from "./Lighthouse";
import { scoreColor } from "./colors";

const SectionLinkAnchor = styled.a`
  text-decoration: none;
`;

const ScoreContainer = styled.div`
  color: ${(props) => props.color};
  width: max-content;
`;

const NumberDisplay = styled.span`
  display: inline-block;
  width: 2em;
`;

export function SectionLink({
  diff,
  children,
}: {
  diff: Differential;
  children: any;
}) {
  return (
    <SectionLinkAnchor
      target="_blank"
      href={getUrl(diff.current_html_url) + "#performance"}
    >
      {children}
    </SectionLinkAnchor>
  );
}

export function Score({ previous, current, value }: ScoreRecord) {
  const color = scoreColor(current);
  return (
    <ScoreContainer color={color}>
      <NumberDisplay>{value || Math.round(current)}</NumberDisplay>
      <ChangeMarker previous={previous} current={current} />
    </ScoreContainer>
  );
}

export function findMin(names, row) {
  const performance = sortBy(names, (name) => row.current.audits[name].score);
  return performance[0];
}

interface ScoreRecord {
  previous?: number;
  current: number;
  value?: any;
}

function ChangeMarker({ previous, current }: ScoreRecord) {
  if (previous === undefined) {
    return (
      <Tooltip title="Value not present in the comparison target">
        <HelpOutline />
      </Tooltip>
    );
  }
  if (previous < current) {
    return (
      <Tooltip title={`Up from ${Math.round(previous)}`}>
        <span>↑</span>
      </Tooltip>
    );
  } else if (previous > current) {
    return (
      <Tooltip title={`Down from ${Math.round(previous)}`}>
        <span>↓</span>
      </Tooltip>
    );
  } else {
    return (
      <Tooltip title="No change from previous">
        <span>→</span>
      </Tooltip>
    );
  }
}
