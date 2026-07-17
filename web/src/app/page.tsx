"use client";

import Link from "next/link";
import Image from "next/image";
import { RevealDiv, RevealSection } from "@/lib/reveal";
import { Icon } from "@/components/icons";

const features = [
  {
    icon: "wheel" as const,
    title: "随机转盘",
    description:
      "每天转动转盘决定今天是「撸」还是「不撸」，让决定不再纠结。",
    ariaLabel: "随机转盘功能",
  },
  {
    icon: "lock" as const,
    title: "时间门控",
    description:
      "次数输入仅在打卡完成后开放，并且等到 20:00 之后才能真正记录，防止作弊。",
    ariaLabel: "时间门控功能",
  },
  {
    icon: "chart" as const,
    title: "数据统计",
    description:
      "GitHub 风格热力图 + 折线图，让你直观看到每天的打卡轨迹和进步曲线。",
    ariaLabel: "数据统计功能",
  },
  {
    icon: "bell" as const,
    title: "每日提醒",
    description:
      "每天 20:00 准时推送打卡提醒，养成习惯从未如此简单。",
    ariaLabel: "每日提醒功能",
  },
  {
    icon: "quote" as const,
    title: "随机一言",
    description:
      "内置 Hitokoto 毒鸡汤一言服务，每天一句扎心话语激励你继续前行。",
    ariaLabel: "随机一言功能",
  },
  {
    icon: "bug" as const,
    title: "调试面板",
    description:
      "内置完整调试系统，点击标题栏的 🐞 即可查看启动日志和数据库状态。",
    ariaLabel: "调试面板功能",
  },
];

const stats = [
  { label: "版本", value: "1.2.0" },
  { label: "Flutter", value: "3.7+" },
  { label: "平台", value: "Android" },
  { label: "协议", value: "MIT" },
];

const steps = [
  { num: "01", title: "打开 App", desc: "每日打开「撸了么」，一切从简" },
  { num: "02", title: "转动转盘", desc: "转动转盘或直接点击按钮完成打卡" },
  { num: "03", title: "查看统计", desc: "热力图记录你的每一天，看见进步" },
];

const techStack = [
  { name: "Flutter", desc: "跨平台 UI 框架" },
  { name: "SQLite", desc: "本地数据存储 (sqflite)" },
  { name: "fl_chart", desc: "统计图表可视化" },
  { name: "Notifications", desc: "每日提醒推送" },
  { name: "Hitokoto API", desc: "一言毒鸡汤服务" },
  { name: "shared_preferences", desc: "轻量配置存储" },
  { name: "Open Source", desc: "MIT 协议开源" },
  { name: "Android", desc: "原生 APK 分发" },
];

function HeatmapSVG() {
  const weeks = 53;
  const days = 7;
  const cellSize = 10;
  const gap = 2;

  // Deterministic seed for consistent data
  const seededRandom = (seed: number) => {
    const x = Math.sin(seed * 9999) * 10000;
    return x - Math.floor(x);
  };

  const cells = [];
  for (let w = 0; w < weeks; w++) {
    for (let d = 0; d < days; d++) {
      const val = seededRandom(w * 7 + d);
      const opacity =
        val < 0.2 ? 0.05 : val < 0.4 ? 0.2 : val < 0.6 ? 0.4 : val < 0.8 ? 0.6 : 0.85;
      cells.push(
        <rect
          key={`${w}-${d}`}
          x={w * (cellSize + gap)}
          y={d * (cellSize + gap)}
          width={cellSize}
          height={cellSize}
          rx="2"
          fill="white"
          fillOpacity={opacity}
          className="transition-all duration-300 hover:fill-opacity-100"
        />
      );
    }
  }

  const width = weeks * (cellSize + gap);
  const height = days * (cellSize + gap);

  return (
    <svg
      viewBox={`0 0 ${width} ${height}`}
      className="w-full"
      style={{ height: "auto", maxHeight: "120px" }}
      role="img"
      aria-label="模拟的打卡热力图，显示一年内的打卡频率分布"
    >
      {cells}
    </svg>
  );
}

function DeviceMockup() {
  return (
    <div className="relative inline-flex flex-col items-center">
      {/* Glow */}
      <div className="absolute inset-0 -m-16 bg-foreground/5 blur-3xl rounded-full" />

      {/* Phone frame */}
      <div className="relative">
        {/* Outer frame */}
        <div
          className="border-2 border-foreground/20 rounded-[2rem] p-2 bg-foreground/5"
          style={{ width: 220, height: 420 }}
        >
          {/* Screen */}
          <div className="w-full h-full rounded-[1.5rem] bg-foreground/10 overflow-hidden relative">
            {/* Status bar */}
            <div className="flex items-center justify-between px-5 pt-3 pb-1">
              <span className="font-mono text-[8px] text-foreground/40">12:00</span>
              <div className="flex gap-1">
                <div className="w-3 h-[6px] bg-foreground/30 rounded-[1px]" />
                <div className="w-3 h-[6px] bg-foreground/30 rounded-[1px]" />
              </div>
            </div>

            {/* App content mock */}
            <div className="px-4 pt-4 pb-2">
              {/* Title */}
              <div className="text-center mb-4">
                <div className="font-mono text-sm font-bold tracking-tight">撸了么</div>
                <div className="font-mono text-[7px] text-foreground/40 mt-0.5">
                  What&apos;s done today?
                </div>
              </div>

              {/* Wheel */}
              <div className="flex justify-center mb-4">
                <div
                  className="relative w-32 h-32 rounded-full border border-foreground/20 flex items-center justify-center"
                  style={{ animation: "spin 20s linear infinite" }}
                >
                  <div className="absolute inset-3 rounded-full border border-dashed border-foreground/10" />
                  <div className="text-center z-10">
                    <div className="font-mono text-xl font-bold">?</div>
                  </div>
                </div>
              </div>

              {/* Buttons */}
              <div className="flex gap-2 mb-3">
                <div className="flex-1 h-7 rounded-full bg-foreground/20 flex items-center justify-center">
                  <span className="font-mono text-[8px]">撸</span>
                </div>
                <div className="flex-1 h-7 rounded-full border border-foreground/20 flex items-center justify-center">
                  <span className="font-mono text-[8px]">不撸</span>
                </div>
              </div>

              {/* Divider */}
              <div className="h-px bg-foreground/10 mb-3" />

              {/* Quote */}
              <div className="text-center">
                <div className="font-mono text-[8px] text-foreground/50 italic">
                  &ldquo;坚持就是胜利&rdquo;
                </div>
              </div>
            </div>

            {/* Bottom nav */}
            <div className="absolute bottom-0 left-0 right-0 flex items-center justify-around py-2 border-t border-foreground/10">
              <div className="w-4 h-4 bg-foreground/30 rounded-sm" />
              <div className="w-4 h-4 border border-foreground/20 rounded-sm" />
              <div className="w-4 h-4 border border-foreground/20 rounded-sm" />
            </div>
          </div>
        </div>

        {/* Home indicator */}
        <div className="absolute -bottom-3 left-1/2 -translate-x-1/2 w-16 h-[5px] bg-foreground/20 rounded-full" />
      </div>

      <style jsx>{`
        @keyframes spin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}

export default function Home() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Skip link for accessibility */}
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-[100] focus:bg-foreground focus:text-background focus:px-4 focus:py-2 focus:rounded-full focus:text-sm"
      >
        跳转到主要内容
      </a>

      {/* Navigation */}
      <nav
        className="sticky top-0 z-50 border-b border-border/50 backdrop-blur-md bg-background/80"
        aria-label="主导航"
      >
        <div className="mx-auto max-w-6xl px-6 h-16 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-2 group" aria-label="返回首页">
            <span className="font-mono text-lg font-bold tracking-tight">
              撸了么
            </span>
            <span className="text-[11px] text-muted-foreground font-mono border border-border rounded-full px-2 py-0.5 group-hover:border-foreground/30 transition-colors">
              v1.2.0
            </span>
          </Link>
          <div className="flex items-center gap-4 sm:gap-6">
            <Link
              href="https://github.com/aoye666/liaoleme"
              className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors hidden sm:flex"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="在 GitHub 上查看源码"
            >
              <Icon name="github" className="w-4 h-4" />
              <span>GitHub</span>
            </Link>
            <Link
              href="https://github.com/aoye666/liaoleme/releases/latest"
              className="inline-flex items-center gap-2 bg-foreground text-background px-4 sm:px-5 py-2 sm:py-2.5 rounded-full text-sm font-semibold hover:opacity-80 transition-opacity"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Icon name="download" className="w-4 h-4" />
              <span className="hidden sm:inline">下载 APK</span>
              <span className="sm:hidden">下载</span>
            </Link>
          </div>
        </div>
      </nav>

      <main id="main-content">
        {/* Hero */}
        <section className="relative overflow-hidden">
          {/* Decorative grid */}
          <div
            className="absolute inset-0 opacity-[0.03]"
            style={{
              backgroundImage:
                "linear-gradient(to right, #fff 1px, transparent 1px), linear-gradient(to bottom, #fff 1px, transparent 1px)",
              backgroundSize: "60px 60px",
            }}
            aria-hidden="true"
          />

          <div className="mx-auto max-w-6xl px-6 pt-20 pb-16 sm:pt-32 sm:pb-24 md:pt-40 md:pb-32 relative">
            <RevealDiv>
              <div className="flex items-center gap-3 mb-8">
                <div className="h-px w-8 bg-foreground" aria-hidden="true" />
                <span className="font-mono text-xs tracking-widest uppercase text-muted-foreground">
                  Flutter · SQLite · Open Source
                </span>
              </div>
            </RevealDiv>

            <RevealDiv delay={100}>
              <h1 className="text-4xl sm:text-5xl md:text-7xl lg:text-8xl font-bold tracking-tight leading-[0.95] mb-8">
                撸了么
                <br />
                <span className="text-muted-foreground">What&apos;s done</span>
                <br />
                <span className="text-muted-foreground">today?</span>
              </h1>
            </RevealDiv>

            <RevealDiv delay={200}>
              <p className="text-base sm:text-lg md:text-xl text-muted-foreground max-w-xl leading-relaxed mb-10">
                一个帮你自律的黑白风每日打卡应用。
                <br className="hidden sm:block" />
                转盘决策 · 时间门控 · 热力图追踪 · 毒鸡汤激励
              </p>
            </RevealDiv>

            <RevealDiv delay={300}>
              <div className="flex flex-col sm:flex-row gap-4">
                <Link
                  href="https://github.com/aoye666/liaoleme/releases/latest"
                  className="inline-flex items-center justify-center gap-2 bg-foreground text-background px-8 py-4 rounded-full text-sm font-semibold hover:opacity-80 transition-opacity focus-visible:ring-2 focus-visible:ring-foreground focus-visible:ring-offset-2 focus-visible:ring-offset-background"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <Icon name="download" className="w-4 h-4" />
                  下载 APK
                </Link>
                <Link
                  href="https://github.com/aoye666/liaoleme"
                  className="inline-flex items-center justify-center gap-2 border border-border px-8 py-4 rounded-full text-sm font-semibold hover:border-foreground/30 transition-colors focus-visible:ring-2 focus-visible:ring-foreground focus-visible:ring-offset-2 focus-visible:ring-offset-background"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <Icon name="github" className="w-4 h-4" />
                  Star on GitHub
                </Link>
              </div>
            </RevealDiv>

            {/* Stats bar */}
            <RevealDiv delay={400}>
              <div className="mt-12 sm:mt-16 pt-6 sm:pt-8 border-t border-border/50 flex flex-wrap gap-6 sm:gap-8 md:gap-16">
                {stats.map((stat) => (
                  <div key={stat.label}>
                    <div className="font-mono text-xl sm:text-2xl font-bold">{stat.value}</div>
                    <div className="text-[11px] sm:text-xs text-muted-foreground mt-1 font-mono">
                      {stat.label}
                    </div>
                  </div>
                ))}
              </div>
            </RevealDiv>
          </div>
        </section>

        {/* App Preview / Device Mockup */}
        <section className="border-y border-border/50" aria-labelledby="preview-heading">
          <div className="mx-auto max-w-6xl px-6 py-16 sm:py-20 md:py-28">
            <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
              <RevealDiv>
                <div>
                  <span className="font-mono text-xs tracking-widest uppercase text-muted-foreground block mb-4">
                    应用预览
                  </span>
                  <h2
                    id="preview-heading"
                    className="text-3xl sm:text-4xl md:text-5xl font-bold tracking-tight leading-tight mb-6"
                  >
                    黑白极简
                    <br />
                    一眼钟情
                  </h2>
                  <p className="text-muted-foreground leading-relaxed max-w-md mb-8">
                    去除一切多余装饰，只保留最核心的打卡功能。
                    黑白配色让注意力聚焦在数据本身，每一次打开都是一种享受。
                  </p>
                  <ul className="space-y-3">
                    {["无干扰纯黑白界面", "流畅转盘动画", "即时数据反馈"].map(
                      (item) => (
                        <li key={item} className="flex items-center gap-3 text-sm">
                          <span className="flex-shrink-0 w-5 h-5 rounded-full bg-foreground/10 flex items-center justify-center">
                            <Icon name="check" className="w-3 h-3" aria-label={item} />
                          </span>
                          <span className="text-muted-foreground">{item}</span>
                        </li>
                      )
                    )}
                  </ul>
                </div>
              </RevealDiv>

              <RevealDiv delay={150}>
                <div className="flex justify-center">
                  <DeviceMockup />
                </div>
              </RevealDiv>
            </div>
          </div>
        </section>

        {/* Features Grid */}
        <section className="border-b border-border/50" aria-labelledby="features-heading">
          <div className="mx-auto max-w-6xl px-6 py-16 sm:py-20 md:py-28">
            <RevealDiv>
              <div className="mb-12 sm:mb-16">
                <span className="font-mono text-xs tracking-widest uppercase text-muted-foreground block mb-4">
                  功能一览
                </span>
                <h2
                  id="features-heading"
                  className="text-3xl sm:text-4xl md:text-5xl font-bold tracking-tight"
                >
                  六个核心功能
                </h2>
              </div>
            </RevealDiv>

            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-px bg-border/50">
              {features.map((feature, i) => (
                <RevealDiv key={feature.title} delay={i * 80}>
                  <div className="bg-background p-6 sm:p-8 md:p-10 group hover:bg-secondary/50 transition-colors duration-300">
                    <div className="flex items-center justify-center w-12 h-12 rounded-xl border border-border/50 mb-6 group-hover:border-foreground/20 group-hover:bg-foreground/5 transition-all duration-300">
                      <Icon
                        name={feature.icon}
                        className="w-6 h-6 text-foreground/70"
                        aria-label={feature.ariaLabel}
                      />
                    </div>
                    <h3 className="text-base sm:text-lg font-semibold mb-3 tracking-tight">
                      {feature.title}
                    </h3>
                    <p className="text-sm text-muted-foreground leading-relaxed">
                      {feature.description}
                    </p>
                    <div className="mt-6 font-mono text-[11px] text-muted-foreground/40">
                      {String(i + 1).padStart(2, "0")}
                    </div>
                  </div>
                </RevealDiv>
              ))}
            </div>
          </div>
        </section>

        {/* How It Works */}
        <section className="border-b border-border/50" aria-labelledby="steps-heading">
          <div className="mx-auto max-w-6xl px-6 py-16 sm:py-20 md:py-28">
            <RevealDiv>
              <div className="mb-12 sm:mb-16">
                <span className="font-mono text-xs tracking-widest uppercase text-muted-foreground block mb-4">
                  使用流程
                </span>
                <h2
                  id="steps-heading"
                  className="text-3xl sm:text-4xl md:text-5xl font-bold tracking-tight"
                >
                  三步开始自律
                </h2>
              </div>
            </RevealDiv>

            <div className="grid sm:grid-cols-3 gap-10 sm:gap-8">
              {steps.map((step, i) => (
                <RevealDiv key={step.num} delay={i * 120}>
                  <div className="relative group">
                    <div className="flex items-center gap-4 mb-4">
                      <span className="font-mono text-4xl sm:text-5xl md:text-6xl font-bold text-border/50">
                        {step.num}
                      </span>
                    </div>
                    <h3 className="text-lg sm:text-xl font-semibold mb-3">
                      {step.title}
                    </h3>
                    <p className="text-sm text-muted-foreground leading-relaxed">
                      {step.desc}
                    </p>
                    {i < 2 && (
                      <div className="hidden sm:block absolute top-6 -right-4 lg:-right-8 w-8 text-border/30">
                        <Icon name="arrowRight" />
                      </div>
                    )}
                  </div>
                </RevealDiv>
              ))}
            </div>
          </div>
        </section>

        {/* Heatmap / Stats */}
        <section className="border-b border-border/50" aria-labelledby="stats-heading">
          <div className="mx-auto max-w-6xl px-6 py-16 sm:py-20 md:py-28">
            <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
              <RevealDiv className="order-2 lg:order-1">
                <div className="border border-border/50 rounded-2xl p-5 sm:p-6 bg-secondary/20">
                  <div className="flex items-center justify-between mb-4">
                    <span className="font-mono text-[11px] sm:text-xs text-muted-foreground">
                      贡献热力图 · 2025
                    </span>
                    <div className="flex items-center gap-1">
                      <span className="text-[10px] sm:text-xs text-muted-foreground">少</span>
                      {[0, 1, 2, 3, 4].map((level) => (
                        <div
                          key={level}
                          className="w-2.5 h-2.5 sm:w-3 sm:h-3 rounded-sm"
                          style={{
                            backgroundColor:
                              level === 0
                                ? "rgba(255,255,255,0.05)"
                                : `rgba(255,255,255,${0.2 + level * 0.2})`,
                          }}
                          aria-hidden="true"
                        />
                      ))}
                      <span className="text-[10px] sm:text-xs text-muted-foreground">多</span>
                    </div>
                  </div>
                  <HeatmapSVG />
                </div>
              </RevealDiv>

              <RevealDiv delay={150} className="order-1 lg:order-2">
                <div>
                  <span className="font-mono text-xs tracking-widest uppercase text-muted-foreground block mb-4">
                    数据可视化
                  </span>
                  <h2
                    id="stats-heading"
                    className="text-3xl sm:text-4xl md:text-5xl font-bold tracking-tight leading-tight mb-6"
                  >
                    GitHub
                    <br />
                    风格热力图
                  </h2>
                  <p className="text-muted-foreground leading-relaxed max-w-md">
                    仿照 GitHub 贡献图设计，用色块深浅直观展示你的打卡频率。
                    配合折线图，让你一眼看出自己的进步曲线和低谷期。
                  </p>

                  <div className="mt-8 grid grid-cols-3 gap-3 sm:gap-4">
                    <div className="border border-border/50 rounded-xl p-3 sm:p-4">
                      <div className="font-mono text-xl sm:text-2xl font-bold">
                        SQLite
                      </div>
                      <div className="text-[11px] sm:text-xs text-muted-foreground mt-1">
                        本地存储
                      </div>
                    </div>
                    <div className="border border-border/50 rounded-xl p-3 sm:p-4">
                      <div className="font-mono text-xl sm:text-2xl font-bold">
                        fl_chart
                      </div>
                      <div className="text-[11px] sm:text-xs text-muted-foreground mt-1">
                        图表库
                      </div>
                    </div>
                    <div className="border border-border/50 rounded-xl p-3 sm:p-4">
                      <div className="font-mono text-xl sm:text-2xl font-bold">
                        实时
                      </div>
                      <div className="text-[11px] sm:text-xs text-muted-foreground mt-1">
                        数据同步
                      </div>
                    </div>
                  </div>
                </div>
              </RevealDiv>
            </div>
          </div>
        </section>

        {/* Tech Stack */}
        <section className="border-b border-border/50" aria-labelledby="tech-heading">
          <div className="mx-auto max-w-6xl px-6 py-16 sm:py-20 md:py-28">
            <RevealDiv>
              <div className="mb-12 sm:mb-16">
                <span className="font-mono text-xs tracking-widest uppercase text-muted-foreground block mb-4">
                  技术栈
                </span>
                <h2
                  id="tech-heading"
                  className="text-3xl sm:text-4xl md:text-5xl font-bold tracking-tight"
                >
                  现代技术构建
                </h2>
              </div>
            </RevealDiv>

            <div className="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-4 gap-px bg-border/50">
              {techStack.map((tech, i) => (
                <RevealDiv key={tech.name} delay={i * 60}>
                  <div className="bg-background p-5 sm:p-6 group hover:bg-secondary/50 transition-colors duration-300">
                    <div className="flex items-center gap-3 mb-2">
                      <div className="w-1.5 h-1.5 rounded-full bg-foreground/30 group-hover:bg-foreground/60 transition-colors" aria-hidden="true" />
                      <h3 className="font-mono text-sm font-semibold">
                        {tech.name}
                      </h3>
                    </div>
                    <p className="text-xs text-muted-foreground pl-5">
                      {tech.desc}
                    </p>
                  </div>
                </RevealDiv>
              ))}
            </div>
          </div>
        </section>

        {/* Mid-page CTA */}
        <section className="border-b border-border/50" aria-label="下载">
          <div className="mx-auto max-w-6xl px-6 py-16 sm:py-20 md:py-24">
            <RevealDiv>
              <div className="border border-border/50 rounded-2xl sm:rounded-3xl p-8 sm:p-12 md:p-16 text-center relative overflow-hidden">
                <div
                  className="absolute inset-0 opacity-[0.02]"
                  style={{
                    backgroundImage:
                      "linear-gradient(to right, #fff 1px, transparent 1px), linear-gradient(to bottom, #fff 1px, transparent 1px)",
                    backgroundSize: "40px 40px",
                  }}
                  aria-hidden="true"
                />
                <div className="relative">
                  <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold tracking-tight mb-4">
                    准备好开始了吗？
                  </h2>
                  <p className="text-muted-foreground max-w-md mx-auto mb-8 text-base sm:text-lg leading-relaxed">
                    下载 APK，用黑白极简的设计记录你的每一个自律瞬间。
                  </p>
                  <Link
                    href="https://github.com/aoye666/liaoleme/releases/latest"
                    className="inline-flex items-center gap-2 bg-foreground text-background px-8 py-4 rounded-full text-sm font-semibold hover:opacity-80 transition-opacity focus-visible:ring-2 focus-visible:ring-foreground focus-visible:ring-offset-2 focus-visible:ring-offset-background"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <Icon name="download" className="w-4 h-4" />
                    获取最新版本
                    <Icon name="arrowRight" className="w-4 h-4" />
                  </Link>
                </div>
              </div>
            </RevealDiv>
          </div>
        </section>

        {/* Final CTA */}
        <section aria-label="下载">
          <div className="mx-auto max-w-6xl px-6 py-16 sm:py-20 md:py-28">
            <RevealDiv>
              <div className="text-center max-w-2xl mx-auto">
                <div className="inline-flex items-center gap-2 border border-border/50 rounded-full px-4 py-1.5 mb-8">
                  <span className="relative flex h-2 w-2">
                    <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-foreground/60 opacity-75" />
                    <span className="relative inline-flex rounded-full h-2 w-2 bg-foreground/80" />
                  </span>
                  <span className="font-mono text-[11px] text-muted-foreground">
                    Open Source · MIT License
                  </span>
                </div>
                <h2 className="text-3xl sm:text-4xl md:text-6xl font-bold tracking-tight mb-6">
                  开始你的
                  <br />
                  自律之旅
                </h2>
                <p className="text-muted-foreground max-w-md mx-auto mb-10 text-base sm:text-lg leading-relaxed">
                  开源免费，无需注册。下载即用，数据全存在本地。
                </p>
                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <Link
                    href="https://github.com/aoye666/liaoleme/releases/latest"
                    className="inline-flex items-center justify-center gap-2 bg-foreground text-background px-8 py-4 rounded-full text-sm font-semibold hover:opacity-80 transition-opacity focus-visible:ring-2 focus-visible:ring-foreground focus-visible:ring-offset-2 focus-visible:ring-offset-background"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <Icon name="download" className="w-4 h-4" />
                    下载最新 APK
                  </Link>
                  <Link
                    href="https://github.com/aoye666/liaoleme"
                    className="inline-flex items-center justify-center gap-2 border border-border px-8 py-4 rounded-full text-sm font-semibold hover:border-foreground/30 transition-colors focus-visible:ring-2 focus-visible:ring-foreground focus-visible:ring-offset-2 focus-visible:ring-offset-background"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <Icon name="github" className="w-4 h-4" />
                    查看源码
                  </Link>
                </div>
              </div>
            </RevealDiv>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-border/50" role="contentinfo">
        <div className="mx-auto max-w-6xl px-6 py-10 sm:py-12">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
            <div>
              <div className="font-mono text-base sm:text-lg font-bold tracking-tight mb-1">
                撸了么
              </div>
              <p className="text-xs sm:text-sm text-muted-foreground">
                © 2024 aoye666 · MIT License
              </p>
            </div>
            <div className="flex items-center gap-6 sm:gap-8">
              <Link
                href="https://github.com/aoye666/liaoleme"
                className="text-xs sm:text-sm text-muted-foreground hover:text-foreground transition-colors focus-visible:underline"
                target="_blank"
                rel="noopener noreferrer"
              >
                GitHub
              </Link>
              <Link
                href="https://github.com/aoye666/liaoleme/releases/latest"
                className="text-xs sm:text-sm text-muted-foreground hover:text-foreground transition-colors focus-visible:underline"
                target="_blank"
                rel="noopener noreferrer"
              >
                Releases
              </Link>
              <span className="text-xs sm:text-sm text-muted-foreground font-mono hidden sm:inline">
                Built with Next.js
              </span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
