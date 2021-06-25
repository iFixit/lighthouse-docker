import { Differential } from "./data_fetch";

export interface RenderInterface {
  data: Differential[];
}

export interface ReportSequenceInterface {
  data: Differential[];
  names: Array<string>;
}
