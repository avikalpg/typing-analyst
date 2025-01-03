import Image from "next/image";
import Link from "next/link";

export default function Home() {
	return (
		<div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen gap-16 sm:p-20 font-[family-name:var(--font-space-mono-regular)]">
			<main className="flex flex-col gap-8 row-start-2 items-center sm:items-start">
				<Image
					className="dark:invert"
					src="/typingAnalystNameTransparent.gif"
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
				<div className="flex gap-4 items-center flex-col sm:flex-row">
					<a
						className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-foreground text-background gap-2 hover:bg-[#383838] dark:hover:bg-[#ccc] text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
						href="/downloads/macos"
					>
						Download for MacOS
					</a>
					<a
						className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-foreground text-background gap-2 hover:bg-[#383838] dark:hover:bg-[#ccc] text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
						href="/downloads/windows"
					>
						Download for Windows
					</a>
					<a
						className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-foreground text-background gap-2 hover:bg-[#383838] dark:hover:bg-[#ccc] text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
						href="/downloads/linux"
					>
						Download for Linux
					</a>
				</div>
				<Link href="/signup" className="mt-4 text-blue-500 hover:underline">
					Sign up for long-term statistics
				</Link>
			</main>
			<footer className="row-start-3 flex gap-6 flex-wrap items-center justify-center">
				{/* Removed Next.js related links */}
			</footer>
		</div>
	);
}
