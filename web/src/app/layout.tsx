import type { Metadata } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
  display: "swap",
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains-mono",
  subsets: ["latin"],
  weight: ["400", "500"],
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://liaoleme.aoye666.github.io"),
  title: {
    default: "录了么 — 每日打卡自控助手",
    template: "%s | 录了么",
  },
  description:
    "一个帮你自律的黑白风每日打卡应用。每日转盘、时间门控、热力图统计、毒鸡汤激励。由 Flutter 构建，开源免费。",
  keywords: [
    "习惯打卡",
    "自律",
    "每日记录",
    "Flutter",
    "Android",
    "自控",
    "习惯追踪",
    "打卡应用",
    "目标管理",
  ],
  authors: [{ name: "aoye666", url: "https://github.com/aoye666" }],
  creator: "aoye666",
  publisher: "aoye666",
  icons: {
    icon: "/favicon.svg",
    apple: "/favicon.svg",
  },
  openGraph: {
    title: "录了么 — 每日打卡自控助手",
    description:
      "一个帮你自律的黑白风每日打卡应用。每日转盘、时间门控、热力图统计、毒鸡汤激励。",
    type: "website",
    locale: "zh_CN",
    siteName: "录了么",
    url: "https://liaoleme.aoye666.github.io",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "录了么 — 每日打卡自控助手",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "录了么 — 每日打卡自控助手",
    description: "一个帮你自律的黑白风每日打卡应用",
    images: ["/og-image.png"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  alternates: {
    canonical: "https://liaoleme.aoye666.github.io",
  },
  verification: {
    other: {
      "msvalidate.01": "7B98E673AC8B2BC131FD06B2C13B8E59",
    },
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-CN" suppressHydrationWarning>
      <body
        className={`${inter.variable} ${jetbrainsMono.variable} font-sans antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
