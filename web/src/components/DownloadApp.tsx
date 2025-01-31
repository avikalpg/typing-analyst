import Link from "next/link";

export const DownloadApp = ({ className }: { className?: string }) => (
	<div className={className}>
		<Link
			className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center btn gap-2 text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
			href="https://github.com/avikalpg/typing-analyst/releases/latest"
		>
			Download for MacOS
		</Link>
		{/* <Link
			className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-secondary text-background gap-2 hover:bg-[#383838] dark:hover:bg-[#ccc] text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
			href="/downloads/windows"
		>
			Download for Windows
		</Link>
		<Link
			className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center cta-btn text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
			href="/downloads/linux"
		>
			Download for Linux
		</Link> */}
	</div>
);