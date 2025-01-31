import { DownloadApp } from "@/components/DownloadApp";
import Image from "next/image";
import Link from "next/link";

export default function Home() {
	return (
		<div className="grid grid-rows-[1fr_20px_2fr] items-center justify-items-center min-h-screen gap-16 sm:p-20 font-[family-name:var(--font-space-mono-regular)] bg-background">
			<main className="flex flex-col gap-8 row-start-2 items-center sm:items-start">
				<Image
					className="dark:invert"
					src="/typingAnalystName.gif"
					alt="Next.js logo"
					width={1024}
					height={480}
					priority
					unoptimized
				/>
				<h1 className="text-2xl font-bold">Welcome to Typing Analyst</h1>
				<p className="text-center sm:text-left">
					Track your typing statistics and improve your typing skills with our desktop applications.
				</p>
				<DownloadApp className="flex gap-4 items-center flex-col sm:flex-row" />
				<Link href="/signup" className="hover:underline">
					Sign up for long-term statistics
				</Link>
			</main>
			<footer className="row-start-3 flex gap-6 flex-wrap items-center justify-center">
				{/* Removed Next.js related links */}
			</footer>
		</div>
	);
}
