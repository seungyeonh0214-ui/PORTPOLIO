// Supabase 연결 정보. Supabase 프로젝트의 Settings → API 에서 복사해 넣습니다.
// anon(publishable) 키는 공개되어도 되는 키입니다. 접근 권한은 supabase-setup.sql 의 보안 규칙이 막습니다.
// service_role(secret) 키는 절대 여기에 넣지 마세요.
window.SUPABASE_CONFIG = {
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY'
};
