"use client";

import axios from "axios";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";

export default function Header() {
	const [isSignedIn, setIsSignedIn] = useState(false);
	const [isMenuOpen, setIsMenuOpen] = useState(false);

	useEffect(() => {
		setIsSignedIn(!!localStorage.getItem("userId"));
	}, []);

	const handleLogout = () => {
		axios.post("/api/auth/logout").then(() => {
			localStorage.removeItem("userId");
			window.location.href = "/"; // Redirect to the desired page after successful login
		}).catch((err) => {
			console.error("Logout failed. Please try again...", err);
		});
	};

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
					<div className="relative">
						<button
							className="w-10 h-10 rounded-full overflow-hidden cursor-pointer p-2 border-none"
							onClick={() => setIsMenuOpen(!isMenuOpen)}
							aria-expanded={isMenuOpen}
							aria-label="Profile menu"
						>
							<Image
								src="/default-avatar.png"
								alt="Profile"
								width={40}
								height={40}
								className="object-cover w-10 h-10"
							/>
						</button>
						{isMenuOpen && (
							<menu className="absolute right-0 mt-2 w-48 py-2 bg-white dark:bg-gray-800 rounded-lg shadow-xl">
								<li>
									<button
										onClick={handleLogout}
										className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700"
									>
										Logout
									</button>
								</li>
							</menu>
						)}
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