export interface LighthouseReport {
  fetchTime: string;
  audits: Audits;
  categories: Categories;
}

interface Categories {
  performance: Score;
}

interface Audits {}

interface Score {
  score: number;
}

export function getUrl(path) {
  return path
}
