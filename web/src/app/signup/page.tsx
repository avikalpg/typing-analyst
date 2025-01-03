'use client'; // This is important for client-side interactivity

import { useState } from 'react';
import axios from 'axios';
import Link from 'next/link';

export default function SignUpPage() {
	const [email, setEmail] = useState('');
	const [password, setPassword] = useState('');
	const [loading, setLoading] = useState(false);
	const [error, setError] = useState<string | null>(null);

	const handleSignUp = async (e: React.FormEvent) => {
		e.preventDefault();
		setLoading(true);
		setError(null);

		try {
			const response = await axios.post('/api/auth/signup', { email, password });
			if (response.status !== 200) {
				setError(response.data.error || 'Sign up failed.');
			} else {
				// Redirect to the desired page after successful login
				window.location.href = '/'; // Or another route
			}
		} catch (err) {
			setError('An unexpected error occurred.');
			console.error(err);
		} finally {
			setLoading(false);
		}
	};

	return (
		<div className="flex flex-col items-center justify-center min-h-screen bg-background">
			<h1 className="text-3xl font-bold mb-8">Login / Sign Up</h1>
			<form className="flex flex-col gap-4 w-full max-w-sm" onSubmit={handleSignUp}>
				<input
					type="email"
					placeholder="Email"
					className="p-2 border border-gray-300 rounded"
					value={email}
					onChange={(e) => setEmail(e.target.value)}
					required
				/>
				<input
					type="password"
					placeholder="Password"
					className="p-2 border border-gray-300 rounded"
					value={password}
					onChange={(e) => setPassword(e.target.value)}
					required
				/>
				{error && <p className="text-red-500">{error}</p>}
				<button
					type="submit"
					className="p-2 bg-foreground text-background rounded hover:bg-[#383838] dark:hover:bg-[#ccc]"
					disabled={loading}
				>
					{loading ? 'Signing up...' : 'Sign Up'}
				</button>
			</form>
			<p className="mt-4">
				Already have an account?{" "}
				<Link href={"/login"} className="text-blue-500 hover:underline">
					Log in
				</Link>
			</p>
		</div>
	);
}