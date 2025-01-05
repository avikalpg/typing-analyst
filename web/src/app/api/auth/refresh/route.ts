import { NextResponse } from 'next/server';
import { supabase } from '@/utils/supabaseClient';
import { cookies } from 'next/headers'; // Import cookies

export async function POST(request: Request) {
	try {
		const cookieStore = await cookies();
		const refreshToken = cookieStore.get('sb-typing-analyst-refresh-token')?.value

		if (!refreshToken) {
			return NextResponse.json({ error: 'Missing refresh token' }, { status: 400 });
		}

		const { data, error } = await supabase.auth.refreshSession({ refresh_token: refreshToken });

		if (error) {
			console.error('Supabase refresh error:', error);
			return NextResponse.json({ error: error.message }, { status: 401 });
		}

		const response = NextResponse.json({ message: 'Token refreshed successfully' }, { status: 200 });
		if (data.session) {
			response.cookies.set({
				name: 'sb-typing-analyst-auth',
				value: data.session.access_token,
				httpOnly: true,
				secure: process.env.NODE_ENV === 'production',
				sameSite: 'strict',
				path: '/',
				maxAge: 60 * 60 * 24 * 30, // 30 days
			});
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
		return response
	} catch (error) {
		console.error('Server error:', error);
		return NextResponse.json({ error: 'An unexpected error occurred.' }, { status: 500 });
	}
}