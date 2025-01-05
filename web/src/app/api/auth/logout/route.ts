import { supabase } from '@/utils/supabaseClient';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
	try {
		// Sign out from Supabase
		const { error } = await supabase.auth.signOut();

		if (error) {
			console.error('[logout] Server error:', error);
			return NextResponse.json({ error: error.message }, { status: 500 });
		}

		// Create response object
		const response = NextResponse.json({ message: 'Logout successful' }, { status: 200 });

		// Clear the authentication cookies
		response.cookies.set({
			name: 'sb-typing-analyst-auth',
			value: '',
			httpOnly: true,
			secure: process.env.NODE_ENV === 'production',
			sameSite: 'strict',
			path: '/',
			maxAge: 0, // Expire immediately
		});

		response.cookies.set({
			name: 'sb-typing-analyst-refresh-token',
			value: '',
			httpOnly: true,
			secure: process.env.NODE_ENV === 'production',
			sameSite: 'strict',
			path: '/',
			maxAge: 0, // Expire immediately
		});

		return response;
	} catch (error) {
		console.error('Server error:', error);
		return NextResponse.json({ error: 'An unexpected error occurred' }, { status: 500 });
	}
}