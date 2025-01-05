import { createClient } from '@supabase/supabase-js'
import { Database } from '../../database.types'

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
	throw new Error('Missing SUPABASE_URL or SUPABASE_ANON_KEY environment variables.');
}

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
	auth: {
		autoRefreshToken: false,
		persistSession: false,
		detectSessionInUrl: false,
	}
});