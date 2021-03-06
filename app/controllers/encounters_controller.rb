class EncountersController < ApplicationController

	def show
		encounter_id = params[:id]
		@encounter = Encounter.find(params[:id])
		@enemies = Enemy.where(encounter_id: encounter_id)
		@players = @encounter.campaign.players
	end

	def edit
		@encounter = Encounter.find(params[:id])
	end

	def units
		encounter = Encounter.find(params[:encounter_id])
		camp = encounter.campaign
		@enemies = encounter.enemies
		@players = camp.players
		@camp = encounter.campaign
		@units = []
		params.each do |player|
			creature = @players.find_by_name(player)
			if creature.nil? == false
		 		@units<<{:name => creature[:name], :initiative => rand(1..20) + creature[:bonus]}
		 	end
		 end
		 @enemies.each do |enemy|
		 	@units<<{:name => enemy.name, :initiative => rand(1..20) + enemy.bonus}
		 end
		 @units.sort_by!{|unit| -unit[:initiative]}
		 render 'turn_order'
	end

	def all
		camp_id = params[:id]
		@encounters = Encounter.where(campaign_id: camp_id)
		render 'index'
	end

	def create
		@encounter = Encounter.new(encounter_params)
		if @encounter.save
      		redirect_to campaign_path(@encounter.campaign_id)
      	else
      		flash[:errors] = @encounter.errors.full_messages
      		redirect_to campaigns_path(@encounter.campaign_id)
      	end
	end

	def update
		@encounter = Encounter.find(params[:id])
		Encounter.where(id: params[:id]).limit(1).update_all(encounter_params)
		redirect_to campaign_path(current_user.id)
	end

	def destroy 
		Encounter.destroy(params[:id])
		redirect_to (:back)
	end

	private
	def encounter_params
		params.require(:encounter).permit(:name, :description, :campaign_id)
	end

end
