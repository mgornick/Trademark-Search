class SearchAdsController < ApplicationController
  # GET /search_ads
  # GET /search_ads.xml
  def index
    @search_ads = SearchAd.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @search_ads }
    end
  end

  # GET /search_ads/1
  # GET /search_ads/1.xml
  def show
    @search_ad = SearchAd.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @search_ad }
    end
  end

  # GET /search_ads/new
  # GET /search_ads/new.xml
  def new
    @search_ad = SearchAd.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @search_ad }
    end
  end

  # GET /search_ads/1/edit
  def edit
    @search_ad = SearchAd.find(params[:id])
  end

  # POST /search_ads
  # POST /search_ads.xml
  def create
    @search_ad = SearchAd.new(params[:search_ad])

    respond_to do |format|
      if @search_ad.save
        flash[:notice] = 'SearchAd was successfully created.'
        format.html { redirect_to(@search_ad) }
        format.xml  { render :xml => @search_ad, :status => :created, :location => @search_ad }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @search_ad.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /search_ads/1
  # PUT /search_ads/1.xml
  def update
    @search_ad = SearchAd.find(params[:id])

    respond_to do |format|
      if @search_ad.update_attributes(params[:search_ad])
        flash[:notice] = 'SearchAd was successfully updated.'
        format.html { redirect_to(@search_ad) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @search_ad.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /search_ads/1
  # DELETE /search_ads/1.xml
  def destroy
    @search_ad = SearchAd.find(params[:id])
    @search_ad.destroy

    respond_to do |format|
      format.html { redirect_to(search_ads_url) }
      format.xml  { head :ok }
    end
  end
end
