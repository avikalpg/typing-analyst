import { supabase } from "@/utils/supabaseClient";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
	try {
		const { email, password } = await request.json();

		if (!email || !password) {
			return NextResponse.json({ error: 'Missing email or password' }, { status: 400 });
		}

		const { data, error } = await supabase.auth.signUp({
			email: email,
			password: password,
		})

		if (error) {
			return NextResponse.json({ error: error.message }, { status: 401 });
		}

		// Check if email confirmation is needed
		if (!data.user?.email_confirmed_at) {
			return NextResponse.json(
				{ message: 'Please check your email to confirm your account' },
				{ status: 200 }
			);
		}

		return NextResponse.json(
			{ message: 'Signup successful' },
			{ status: 200 }
		);
	} catch (error) {
		console.error('[signup] Server error:', error);
		return NextResponse.json({ error: 'An unexpected error occurred.' }, { status: 500 });
	}
}