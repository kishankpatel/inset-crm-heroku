module GoalsHelper
	def deals_count assigned_to, startdate, end_date, goal_duration, goal_currency, deal_stage_id, goal_type
		stage = @current_organization.deal_statuses.where("lower(name)=?","won").first
		if goal_duration == "Week"
			if goal_type == "won"
				@deal_trans = @current_organization.deal_transactions.where("(created_at >= ? AND  created_at <= ?) AND assigned_to=? AND deal_status_id=?" , startdate.beginning_of_day, end_date.end_of_day, assigned_to, stage.id).count
			else
				@deal_trans = @current_organization.deal_transactions.where("(created_at >= ? AND  created_at <= ?) AND assigned_to=? AND deal_status_id=?" , startdate.beginning_of_day, end_date.end_of_day, assigned_to, deal_stage_id).count
			end
		else
			if goal_type == "won"
				@deal_trans = @current_organization.deal_transactions.where("(created_at >= ? AND  created_at <= ?) AND assigned_to=? AND deal_status_id=?" , startdate.beginning_of_day, end_date.end_of_day, assigned_to, stage.id).count
			else
				@deal_trans = @current_organization.deal_transactions.where("(created_at >= ? AND  created_at <= ?) AND assigned_to=? AND deal_status_id=?" , startdate.beginning_of_day, end_date.end_of_day, assigned_to, deal_stage_id).count
			end
		end
		return @deal_trans
	end
  
	def deals_value assigned_to, startdate, end_date, goal_duration, goal_currency, deal_stage_id, goal_type
		stage = @current_organization.deal_statuses.where("lower(name)=?","won").first
		if goal_duration == "Week"
			if goal_type == "won"
				@deal_trans = @current_organization.deal_transactions.where("(created_at >= ? AND  created_at <= ?) AND assigned_to=? AND deal_status_id=?" , startdate.beginning_of_day, end_date.end_of_day, assigned_to, stage.id)
			else
				@deal_trans = @current_organization.deal_transactions.where("(created_at >= ? AND  created_at <= ?) AND assigned_to=? AND deal_status_id=?" , startdate.beginning_of_day, end_date.end_of_day, assigned_to, deal_stage_id)
			end
		else
			if goal_type == "won"
				@deal_trans = @current_organization.deal_transactions.where("(created_at >= ? AND  created_at <= ?) AND assigned_to=? AND deal_status_id=?" , startdate.beginning_of_day, end_date.end_of_day, assigned_to, stage.id)
			else
				@deal_trans = @current_organization.deal_transactions.where("(created_at >= ? AND  created_at <= ?) AND assigned_to=? AND deal_status_id=?" , startdate.beginning_of_day, end_date.end_of_day, assigned_to, deal_stage_id)
			end
			#@deal_trans = @current_organization.deal_transactions.where(:created_at => startdate..end_date.end_of_month, :assigned_to => assigned_to, :deal_status_id =>deal_stage_id)
		end

		@goal_value=0
		goal_currency=":"+goal_currency.downcase
		@deal_trans.uniq_by(&:deal_id).uniq.each do |deal_trans|
			deal=deal_trans.deal
			currency = get_deal_amount_type(deal)
	        if eval(currency) == :dzd || eval(goal_currency) == :dzd
	          begin
	            from=eval(currency).upcase.to_s.chomp(':')
	            to=eval(goal_currency).upcase.to_s.chomp(':')
	            dzd_conversion = URI('https://free.currencyconverterapi.com/api/v5/convert?q='+from+'_'+to+'&compact=y').read
	            @goal_value = @goal_value + deal.amount*dzd_conversion.match(/[.\d]+/)[0].to_f
	          rescue
	            0
	          end
	        else
	          begin
	            @goal_value = @goal_value + deal.amount.in(eval(currency)).to(eval(goal_currency)).to_f
	          rescue
	            0
	          end
	        end
		end
		return @goal_value
	end
end
