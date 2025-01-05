-- Purpose: Set up the database schema for the typing stats service.
CREATE TABLE public.typing_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    start_timestamp TIMESTAMPTZ NOT NULL,
    end_timestamp TIMESTAMPTZ,
    application TEXT NOT NULL,
    device_id TEXT,
    keyboard_id TEXT,
    locale TEXT,
    per_second_data JSONB, -- [{ "timestamp": "2024-10-27T10:00:00Z", "keystrokes": 15, "words": 2, "backspaces": 1, "accuracy": 98, "keyStats": { "alphabets": 12, "numbers": 2, "symbols": 1, "backspaces": 1, "modifiers": 0 }}, ...]
    chunk_stats JSONB -- { "totalKeystrokes": 1500, "totalWords": 300, "accuracy": 95, "peakSpeed (Max keystrokes in one second)": 70,(Max keystrokes in one second) "longestStreak (Longest uninterrupted keystroke streak)": 45}
);

ALTER TABLE public.typing_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own stats"
ON public.typing_stats
USING (auth.uid() = user_id);