// Colors from https://www.nature.com/articles/nmeth.1618
export function scoreColor(value: number): string {
  const safeRed = "rgb(213, 94, 0)";
  const safeGreen = "rgb(53, 155, 115)";
  const safeYellow = "rgb(230, 159, 0)";
  if (value < 50) {
    return safeRed;
  }
  if (value < 90) {
    return safeYellow;
  }
  return safeGreen;
}

// Colors from https://www.nature.com/articles/nmeth.1618
export function diffColor(value: number): string {
  const opacity = Math.abs(value / 100);
  if (value < -5) {
    return `radial-gradient(closest-side, rgba(213, 94, 0, ${opacity}), white)`;
  }
  if (value > 5) {
    return `radial-gradient(closest-side, rgba(0, 158, 115, ${opacity}), white)`;
  }
  return "white";
}
