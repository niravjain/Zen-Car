class CustomersController < ApplicationController
  #before_action :set_customer, only: [:show, :edit, :update, :destroy]
  before_action :set_customer, only: [:show, :edit, :update, :destroy]
  before_action :authorize_admin, only: [:create, :show, :edit, :update, :destroy]
  # Backend validation left

  # GET /customers
  # GET /customers.json
  def index
    search_order_per_customer()
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    search_order_per_customer()
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit

  end

  # POST /customers
  # POST /customers.json
  def create

    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: 'Customer was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy

    if @customer == current_customer and @customer.admin?
      flash[:notice] = "ERROR: Admin cannot delete himself"
      redirect_to root_path and return
    end

    @order = Order.where(:customer_id => @customer.id).first
    if not @order.nil? and (@order.status == "Initated" or @order.status == "In Progress")
      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Cannot delete Customer due his/her current order' }
        format.json { head :no_content }
      end
    else
      @customer.destroy
      respond_to do |format|
        format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.fetch(:customer, {})
      params.require(:customer).permit(:id, :email, :password, :salt, :encrypted_password, :admin, :superadmin)
    end

    def search_order_per_customer
      if params.has_key?("id")
        cust_id = params[:id]
      else
        cust_id = current_customer.id
      end

      orders = Order.where(:customer_id => cust_id).where(:status => ["Initiated","In Progress"])
      if orders.length > 0
        puts "in order"
        @order = orders.first
      end

      @customers = Customer.all
      @cars = Car.all
      @orders = Order.all
      @recommendations = Recommendation.all
      last_successful_order = Order.where(:customer_id => cust_id).where(:status => "Completed").order(returned_at: :DESC).first
      puts "last_successful_order ",last_successful_order
      if !last_successful_order.nil?
          puts "last_successful_order", last_successful_order.total_charges
        @rental_charge = last_successful_order.total_charges
      end
    end

end
