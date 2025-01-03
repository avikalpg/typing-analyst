import { supabase } from '@/utils/supabaseClient';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
	try {
		const { email, password } = await request.json();

		if (!email || !password) {
			return NextResponse.json({ error: 'Missing email or password' }, { status: 400 });
		}

		const { data, error } = await supabase.auth.signInWithPassword({
			email,
			password,
		});

		if (error) {
			console.error('[login] Server error:', error);
			return NextResponse.json({ error: error.message }, { status: 401 }); // Or another appropriate status code
		}

		const response = NextResponse.json({ message: 'Login successful', userId: data.user.id }, { status: 200 });

		if (data.session) {
			// Set the access token cookie
			response.cookies.set({
				name: 'sb-typing-analyst-auth',
				value: data.session.access_token,
				httpOnly: true,
				secure: process.env.NODE_ENV === 'production',
				sameSite: 'strict', // Important for CSRF protection
				path: '/',
				maxAge: 60 * 60 * 24 * 30, // 30 days
			});

			// Set the refresh token cookie (Crucial for session persistence)
			response.cookies.set({
				name: 'sb-typing-analyst-refresh-token',
				value: data.session.refresh_token,
				httpOnly: true,
				secure: process.env.NODE_ENV === 'production',
				sameSite: 'strict',
				path: '/',
				maxAge: 60 * 60 * 24 * 30, // 30 days
			});
		}

		return response;
	} catch (error) {
		console.error('Server error:', error);
		return NextResponse.json({ error: 'An unexpected error occurred.' }, { status: 500 });
	}
}