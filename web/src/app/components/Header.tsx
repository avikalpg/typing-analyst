"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";

export default function Header() {
	const [isSignedIn, setIsSignedIn] = useState(false);

	useEffect(() => {
		setIsSignedIn(!!localStorage.getItem("userId"));
	}, []);

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
					<Image src="https://img.shields.io/github/stars/avikalpg/typing-analyst" alt="GitHub stars" width={100} height={24} />
				</Link>
				{isSignedIn ? (
					<div className="w-10 h-10 rounded-full overflow-hidden bg-foreground">
						<Image
							src="/default-avatar.png" // Add a default avatar image to your public folder
							alt="Profile"
							width={40}
							height={40}
							className="object-cover"
						/>
					</div>
				) : (
					<>
						<Link href="/login" className="btn">
							Login
						</Link>
						<Link href="/signup" className="cta-btn">
							Sign Up
						</Link>
					</>
				)}
			</div>
		</header>
	);
}