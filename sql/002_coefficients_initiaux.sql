insert into ds2.coef_source(source, coef , date_debut)
select distinct source, 1 , date '2026-10-02'
from public.news
on conflict (source , date_debut) do nothing;

SELECT * FROM ds2.coef_source ORDER BY source;