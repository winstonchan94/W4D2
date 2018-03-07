class CatRentalRequestsController < ApplicationController
  def index
    @cat_rental_requests = CatRentalRequest.all
    render :index
  end

  def show
    @cat_rental_request = CatRentalRequest.find(params[:id])
    render :show
  end

  def edit
    @cat_rental_request = CatRentalRequest.find(params[:id])
    render :edit
  end

  def update
    @cat_rental_request = CatRentalRequest.find(params[:id])
    if @cat_rental_request.update(cat_rental_request_params)
      redirect_to cat_rental_request_url(@cat_rental_request)
    else
      render json: @cat_rental_request.errors.full_messages, status: 422
    end
  end

  def new
    @cat_rental_request = CatRentalRequest.new
    render :new
  end

  def approve
    @cat_rental_request = CatRentalRequest.find(params[:id])
    @cat_rental_request.approve!
    redirect_to cat_rental_request_url(@cat_rental_request)
  end

  def deny
    @cat_rental_request = CatRentalRequest.find(params[:id])
    @cat_rental_request.deny!
    redirect_to cat_rental_request_url(@cat_rental_request)
  end

  def create
    @cat_rental_request = CatRentalRequest.new(cat_rental_request_params)
    if @cat_rental_request.save
      redirect_to cat_rental_request_url(@cat_rental_request)
    else
      render json: @cat_rental_request.errors.full_messages, status: 422
    end
  end

  def destroy
    @cat_rental_request = CatRentalRequest.find(params[:id])
    @cat_rental_request.destroy
    redirect_to cat_rental_requests_url
  end

  private

  def cat_rental_request_params
    params.require(:cat_rental_request).permit(:cat_id, :start_date, :end_date, :status)
  end
end
