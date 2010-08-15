class TrademarksController < ApplicationController
  # GET /trademarks
  # GET /trademarks.xml
  def index
    @trademarks = Trademark.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trademarks }
    end
  end

  # GET /trademarks/1
  # GET /trademarks/1.xml
  def show
    if params[:search_page]
      @trademark = Trademark.find(params[:id])
      html = @trademark.google_search_page if params[:search_page] == 'google'
      html = @trademark.yahoo_search_page if params[:search_page] == 'yahoo'
      html = @trademark.bing_search_page if params[:search_page] == 'bing'
      
      filename = params[:filename] || "#{Time.now.hash}.pdf"
      filepath = "#{RAILS_ROOT}/tmp/#{filename}"
      PDFKit.new(html).to_file(filepath)

      send_file filepath
    else
      @trademark = Trademark.find(params[:id], :include => [:search_ads, :search_results])
    end
  end

  # GET /trademarks/new
  # GET /trademarks/new.xml
  def new
    @trademark = Trademark.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trademark }
    end
  end

  # GET /trademarks/1/edit
  def edit
    @trademark = Trademark.find(params[:id])
  end

  # POST /trademarks
  # POST /trademarks.xml
  def create
    @trademark = Trademark.new(params[:trademark])

    respond_to do |format|
      if @trademark.save
        flash[:notice] = 'Trademark was successfully created.'
        format.html { redirect_to(@trademark) }
        format.xml  { render :xml => @trademark, :status => :created, :location => @trademark }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trademark.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trademarks/1
  # PUT /trademarks/1.xml
  def update
    @trademark = Trademark.find(params[:id])

    respond_to do |format|
      if @trademark.update_attributes(params[:trademark])
        flash[:notice] = 'Trademark was successfully updated.'
        format.html { redirect_to(@trademark) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trademark.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trademarks/1
  # DELETE /trademarks/1.xml
  def destroy
    @trademark = Trademark.find(params[:id])
    @trademark.destroy

    respond_to do |format|
      format.html { redirect_to(trademarks_url) }
      format.xml  { head :ok }
    end
  end
end
