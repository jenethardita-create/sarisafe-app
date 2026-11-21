import { createClient } from
  'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = 'https://lcfdxountexmtmnhuynw.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_QJtZjV-w2YgPZPN7LryR7g_KvhB6ZRb';

export const supabase = createClient(
  SUPABASE_URL,
  SUPABASE_PUBLISHABLE_KEY
);

console.log("Supabase client initialized:", supabase);

async function testSupabaseConnection() {
    const { data, error } = await supabase
        .from('sarisafe_stores')
        .select('*');

    if (error) {
        console.error('Database connection failed:', error.message);
    } else {
        console.log('Database connection successful!');
        console.log('Stores:', data);
    }
}

testSupabaseConnection();