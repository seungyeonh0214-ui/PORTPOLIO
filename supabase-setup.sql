-- 방문 예약 저장소 만들기
-- Supabase 대시보드 → SQL Editor 에 이 파일 전체를 붙여 넣고 Run 을 한 번 누르세요.
-- 아래 is_admin() 안의 이메일은 관리자 로그인에 쓸 이메일과 같아야 합니다.

create table public.reservations (
  no          bigint generated always as identity primary key,   -- 예약 번호 (화면에는 R-0001 형태로 표시)
  name        text not null check (char_length(name) between 1 and 100),
  email       text not null check (email ~* '^[^\s@]+@[^\s@]+\.[^\s@]{2,}$'),
  visit_date  date not null,
  visit_time  text not null check (visit_time in
                ('13:00','13:30','14:00','14:30','15:00','15:30','16:00','16:30','17:00','17:30','18:00')),
  purpose     text not null check (char_length(purpose) between 1 and 2000),
  status      text not null default '접수' check (status in ('접수','확정','변경 요청','취소')),
  created_at  timestamptz not null default now(),
  -- 예약을 구분하는 기준: 신청자(이름+이메일) + 방문 희망 시간.
  -- 같은 사람이 다른 시간에 신청하면 새 예약 번호가 생기고, 완전히 같은 신청은 한 번만 접수됩니다.
  constraint reservations_identity unique (name, email, visit_date, visit_time)
);
-- 방문 희망 시간이 겹치지 않게 하는 규칙은 supabase-slots.sql 에 있습니다. 이 파일 다음에 실행하세요.

create or replace function public.is_admin() returns boolean
language sql stable as $$
  select coalesce((auth.jwt() ->> 'email') = 'seungyeonh0214@gmail.com', false);
$$;

alter table public.reservations enable row level security;

grant insert on public.reservations to anon, authenticated;
grant select, update on public.reservations to authenticated;

-- 누구나 예약을 신청할 수 있지만, 처음 상태는 '접수'만 가능
create policy "누구나 예약 신청" on public.reservations
  for insert to anon, authenticated with check (status = '접수');

-- 예약 목록을 보고 상태를 바꾸는 것은 관리자만 가능
create policy "관리자만 조회" on public.reservations
  for select to authenticated using (public.is_admin());
create policy "관리자만 상태 변경" on public.reservations
  for update to authenticated using (public.is_admin()) with check (public.is_admin());
