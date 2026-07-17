import { type ReactNode } from "react";

type RevealProps = {
  children: ReactNode;
  className?: string;
  delay?: number;
};

export function RevealDiv(props: RevealProps) {
  const cn = "reveal" + (props.className ? " " + props.className : "");
  const ad = props.delay ? { animationDelay: props.delay + "ms" } : {};

  return (
    <div className={cn} style={ad}>
      {props.children}
    </div>
  );
}

export function RevealSection(props: RevealProps) {
  const cn = "reveal" + (props.className ? " " + props.className : "");
  const ad = props.delay ? { animationDelay: props.delay + "ms" } : {};

  return (
    <section className={cn} style={ad}>
      {props.children}
    </section>
  );
}
