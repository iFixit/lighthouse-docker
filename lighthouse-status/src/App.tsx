import React from "react";
import "./App.css";
import { useAsync } from "react-async";
import styled from "@emotion/styled";
import { getData, getParam, InvalidSelectorError } from "./data_fetch";
import { StatusReport } from "./StatusReport";
import { DiffReport } from "./DiffReport";

const SplitScreen = styled.div`
  display: flex;
`;

function App() {
  const current = getParam("current");
  const previous = getParam("previous");
  const dataFetch = React.useCallback(() => getData(previous, current), [
    previous,
    current,
  ]);
  const { data, error, isPending } = useAsync({ promiseFn: dataFetch });

  if (error) {
    if (
      error instanceof InvalidSelectorError &&
      /previous/i.test(error.message) &&
      previous
    ) {
      // If it's complaining about the `previous` selector and the user's provided one, fall back to the status view
      const url = new URL(window.location.href);
      url.searchParams.delete("previous");
      window.location.assign(url.href);
    }
    return <span>Error! {String(error)}</span>;
  }

  if (isPending || data === undefined) {
    return <span>Wait for it!</span>;
  }

  const demo = getParam("demo");

  if (demo) {
    return (
      <SplitScreen>
        <DiffReport data={data} />
        <StatusReport data={data} />
      </SplitScreen>
    );
  }

  if (previous) {
    return <DiffReport data={data} />;
  } else {
    return <StatusReport data={data} />;
  }
}

export default App;
