class MembersController < ApplicationController
  def index
    authorize Member
    @pagy, @members = pagy(
      Member
        .filter_by(member_search_params.slice(:can_rent))
        .search(member_search_params[:search])
        .order(id: :asc),
      items: member_search_params[:max_results] || Pagy::DEFAULT[:items]
    )
    respond_to do |format|
      format.html
      format.json { render json: @members }
    end
  end

  def new
    @member = Member.new
    authorize @member
  end

  def create
    authorize Member
    @member = Member.new(member_params)
    if @member.save
      flash[:snack_success] = I18n.t('successfully_created_member_name', name: @member.name)
      redirect_to members_path
    else
      flash[:form_errors] = @member.errors.full_messages
      render 'new'
    end
  end

  def member_params
    mp = params
      .require(:member)
      .transform_values { |x| x.strip.gsub(/\s+/, ' ') if x.respond_to?('strip') }
      .reject { |_, v| v.blank? }
      .permit(:name, :personal_number, :email, :phone, :tamil_name, :date_of_birth, :date_of_retirement, :custom_number, :auto_assign_custom_number)

    # If auto_assign_custom_number is present and true, remove custom_number so model can auto-assign
    auto_assign = mp.delete(:auto_assign_custom_number)
    if auto_assign.present? && ActiveModel::Type::Boolean.new.cast(auto_assign)
      mp[:custom_number] = nil
    end
    mp
  end

  def member_search_params
    params
      .transform_values { |x| x.strip.gsub(/\s+/, ' ') if x.respond_to?('strip') }
      .permit(:search, :max_results, :can_rent)
  end
end
