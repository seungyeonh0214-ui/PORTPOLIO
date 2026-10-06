-- 예약 시간 중복 방지 (supabase-setup.sql 을 이미 실행한 프로젝트에 추가로 한 번 실행)
-- Supabase 대시보드 → SQL Editor 에 이 파일 전체를 붙여 넣고 Run.

-- 1) 같은 날짜·시간에는 '취소'가 아닌 예약이 하나만 존재할 수 있음.
--    화면에서 막는 것과 별개로, 두 사람이 동시에 눌러도 저장소가 두 번째 예약을 거절합니다.
--    (이미 같은 날짜·시간에 예약이 둘 이상 있으면 이 줄에서 오류가 납니다. 그때는 한쪽을 '취소'로 바꾼 뒤 다시 실행하세요.)
create unique index if not exists reservations_slot_taken
  on public.reservations (visit_date, visit_time)
  where status <> '취소';

-- 2) 예약 페이지가 "이미 예약된 날짜·시간"만 읽어 갈 수 있는 창구.
--    이름·이메일·방문 목적은 내보내지 않습니다.
create or replace function public.booked_slots()
returns table (visit_date date, visit_time text)
language sql stable security definer set search_path = public as $$
  select r.visit_date, r.visit_time
  from public.reservations r
  where r.status <> '취소'
    and r.visit_date >= (now() at time zone 'Asia/Seoul')::date;
$$;

revoke all on function public.booked_slots() from public;
grant execute on function public.booked_slots() to anon, authenticated;
