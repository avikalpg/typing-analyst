'use client'; // This is important for client-side interactivity

import { useState } from 'react';
import axios from 'axios';
import Link from 'next/link';

export default function LoginPage() {
	const [email, setEmail] = useState('');
	const [password, setPassword] = useState('');
	const [loading, setLoading] = useState(false);
	const [error, setError] = useState<string | null>(null);

	const handleLogin = async (e: React.FormEvent) => {
		e.preventDefault();
		setLoading(true);
		setError(null);

		try {
			const response = await axios.post('/api/auth/login', { email, password });
			if (response.status !== 200) {
				setError(response.data.error || 'Login failed.');
			} else {
				localStorage.setItem('userId', response.data.userId);
				window.location.href = '/typing-stats'; // Redirect to the desired page after successful login
			}
		} catch (err) {
			setError('An unexpected error occurred.');
			console.error(err);
		} finally {
			setLoading(false);
		}
	};

	return (
		<div className="flex flex-col items-center justify-center -mt-36 min-h-screen bg-background">
			<h1 className="text-3xl font-bold mb-8">Login</h1>
			<form className="flex flex-col gap-4 w-full max-w-sm" onSubmit={handleLogin}>
				<input
					type="email"
					placeholder="Email"
					className="p-2 border border-gray-300 rounded"
					value={email}
					onChange={(e) => setEmail(e.target.value)}
					autoComplete='email'
					required
				/>
				<input
					type="password"
					placeholder="Password"
					className="p-2 border border-gray-300 rounded"
					value={password}
					onChange={(e) => setPassword(e.target.value)}
					autoComplete='current-password'
					required
				/>
				{error && <p className="text-red-500">{error}</p>}
				<button
					type="submit"
					className="!p-2 cta-btn"
					disabled={loading}
				>
					{loading ? 'Logging in...' : 'Login'}
				</button>
			</form>
			<p className="mt-4">
				Don&apos;t have an account?{" "}
				<Link href={"/signup"} className="hover:underline">
					Sign up
				</Link>
			</p>
		</div>
	);
}