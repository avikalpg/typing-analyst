import type { Metadata } from "next";
import { Space_Mono } from "next/font/google";
import "./globals.css";
import Header from "./components/Header";
import { Analytics } from "@vercel/analytics/next";

const spaceMonoRegular = Space_Mono({
  variable: "--font-space-mono-regular",
  weight: "400",
  subsets: ["latin"],
});

const spaceMonoBold = Space_Mono({
  variable: "--font-space-mono-bold",
  weight: "700",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Typing Analyst",
  description: "Continuously monitory your typing speed and accuracy",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${spaceMonoRegular.variable} ${spaceMonoBold.variable} antialiased`}
      >
        <Header />
        {children}
        <Analytics />
      </body>
    </html>
  );
}
