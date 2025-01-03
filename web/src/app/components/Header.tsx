import Image from "next/image";
import Link from "next/link";

export default function Header() {
	return (
		<header className="w-full flex justify-between items-center p-4">
			<div className="flex items-center">
				<Link href="/">
					<Image
						src="/TypingAnalystName.png"
						alt="Typing Analyst Logo"
						className="dark:invert"
						width={250}
						height={50}
					/>
				</Link>
			</div>
			<div className="flex items-center gap-4">
				<Link href="https://github.com/avikalpg/typing-analyst" target="_blank" rel="noopener noreferrer">
					<img src="https://img.shields.io/github/stars/avikalpg/typing-analyst" alt="GitHub stars" className="h-6" />
				</Link>
				<Link href="/login" className="btn">
					Login
				</Link>
				<Link href="/signup" className="cta-btn">
					Sign Up
				</Link>
			</div>
		</header>
	);
}
