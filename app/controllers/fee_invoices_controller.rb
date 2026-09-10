class FeeInvoicesController < ApplicationController
  before_action -> { authorize!("fees.read") },  only: [ :index, :show ]
  before_action -> { authorize!("fees.write") }, except: [ :index, :show ]
  before_action :set_invoice, only: [ :show, :edit, :update, :destroy ]

  def index
    scope = FeeInvoice.includes(student: { enrollments: { section: :grade } })
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.overdue if params[:overdue] == "1"
    scope = scope.where(student_id: Student.search(params[:q])) if params[:q].present?
    @invoices = paginate(scope.order(issue_date: :desc, id: :desc))
    @totals = { billed: FeeInvoice.sum(:total), collected: FeeInvoice.sum(:paid),
                due: FeeInvoice.unpaid.sum("total + fine - discount - paid") }
  end

  def show
    @payment = FeePayment.new(amount: @invoice.balance)
  end

  def new
    @invoice = FeeInvoice.new(issue_date: Date.current, due_date: Date.current + 9, academic_year: Current.academic_year)
    @invoice.fee_invoice_items.build
  end

  def edit; end

  def create
    @invoice = FeeInvoice.new(invoice_params.merge(academic_year: Current.academic_year))
    if @invoice.save
      @invoice.refresh_totals!
      redirect_to @invoice, notice: "Invoice raised."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @invoice.update(invoice_params)
      @invoice.refresh_totals!
      redirect_to @invoice, notice: "Updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.update!(status: "cancelled")
    redirect_to fees_path, notice: "Invoice cancelled."
  end

  private

  def set_invoice = @invoice = FeeInvoice.find(params[:id])

  def invoice_params
    params.expect(fee_invoice: [ :student_id, :period, :issue_date, :due_date, :discount, :fine,
                                fee_invoice_items_attributes: [ [ :id, :fee_head_id, :description, :amount, :_destroy ] ] ])
  end
end
