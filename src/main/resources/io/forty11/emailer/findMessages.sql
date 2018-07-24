select * from
(
	select * from
	(
		select m.*, sm.order as nextOrder, ls.listId, sm.sequenceId,startDate,endDate,paused,ls.subjectPrefix, ls.lastDate,ls.sendHour,ls.tz,
	  		   (if(sm.dayOfMonth is not null, 3, 0) + if(sm.month is not null, 3, 0)  + if(sm.year is not null, 3, 0) + if(sm.dayOfWeek is not null, 2, 0)) as rank
		from ListSequence ls
		join SequenceMessage sm on ls.sequenceId = sm.sequenceId
		join Message m on sm.messageId = m.id
		where	(
					sm.dayOfMonth LIKE CONCAT('%,', DAYOFMONTH(CONVERT_TZ(UTC_TIME(), 'UTC', ls.tz)), ',%')
					and( sm.month is null or sm.month LIKE CONCAT('%,', MONTH(CONVERT_TZ(UTC_TIME(), 'UTC', ls.tz)), ',%'))
					and( sm.year is null or sm.year LIKE CONCAT('%,', YEAR(CONVERT_TZ(UTC_TIME(), 'UTC', ls.tz)), ',%'))
			    )
			    or 
			   	(
		    	     sm.dayOfWeek LIKE CONCAT('%,', DAYOFWEEK(CONVERT_TZ(UTC_TIME(), 'UTC', ls.tz)), ',%') 
		        	 and( sm.month is null or sm.month LIKE CONCAT('%,', MONTH(CONVERT_TZ(UTC_TIME(), 'UTC', ls.tz)), ',%'))
			         and( sm.year is null or sm.year LIKE CONCAT('%,', YEAR(CONVERT_TZ(UTC_TIME(), 'UTC', ls.tz)), ',%'))
			    )
	
		union
	
		select m.*, q.nextOrder, q.listId, sm.sequenceId, startDate,endDate,paused,ls.subjectPrefix, ls.lastDate,sendHour, ls.tz,1 as rank
		from Message m
		join SequenceMessage sm on m.id = sm.messageId
		join ListSequence ls on sm.sequenceId = ls.sequenceId
		join 
		(
			select ls.listId, ls.sequenceId, min(sm.order) as nextOrder, lastDate
			from ListSequence ls 
			join SequenceMessage sm  on sm.sequenceId = ls.sequenceId and (ls.lastOrder is null || sm.order > ls.lastOrder)
			group by ls.listId, ls.sequenceId
		)q on q.sequenceId = sm.sequenceId and q.nextOrder = sm.order and ls.listId = q.listId
	
	)q
	order by listId, sequenceId, rank desc
)q
where (paused is null or paused = false)
      and (startDate is null OR startDate < date(CONVERT_TZ(UTC_TIME(), 'UTC', tz))) 
	  and (endDate is null || endDate > date(CONVERT_TZ(UTC_TIME(), 'UTC', tz)))
	  and (lastDate is null or lastDate < date(CONVERT_TZ(UTC_TIME(), 'UTC', tz)))
	  and (sendHour is null || sendHour <= hour(CONVERT_TZ(UTC_TIME(), 'UTC', tz)))

group by listId, sequenceId
