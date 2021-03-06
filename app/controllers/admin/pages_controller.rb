class Admin::PagesController < AdminController

  def index
    @pages = Page.all
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])

    if @page.update_attributes(params[:page])
      redirect_to [:admin, :pages], notice: "Page was updated!"
    else
      render :edit
    end
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])

    if @page.save
      redirect_to [:admin, :pages], notice: "Page was created!"
    else
      render :new
    end
  end

  def destroy
    @page = Page.find(params[:id])

    if @page.destroy
      redirect_to [:admin, :pages], notice: "Page was deleted!"
    end
  end

end