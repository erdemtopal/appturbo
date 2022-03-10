class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]

  # GET /messages or /messages.json
  def index
    @messages = Message.order(created_at: :desc)
  end

  # GET /messages/1 or /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages or /messages.json
  def create
    @message = Message.new(message_params)

    respond_to do |format|
      if @message.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('message_body_form', partial: "messages/form", locals: { message: Message.new } ),
            turbo_stream.prepend('messages', partial: "messages/message", locals: {message: @message}),
            turbo_stream.update('sayi_revize', Message.count ),
            turbo_stream.update('notice1', "Message #{Message.count} created" )
            #sadece string yazsak da içine yazacaktı notice'in
          ]

          # ilgili id içinde Message.new 'i  çalıştırdı. dolayısı ile kaydedilince form sıfırlandı
          #prepend en üste ekliyor. append sona ekliyor. turbo stream özelliği. 
          #messages div'inin içine prepend yapıyor. partial bizim tablomuz. local yüklencek yer. aynı sayfayı yüklemeye devam et diyor. 
          # ilgili partial her zaman atıfta bulunulan div in içinde. 
        end
        format.html { redirect_to message_url(@message), notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @message }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('message_body_form', partial: "messages/form", locals: { message: @message } )
          ]
          # @message komutu lokalde,  messages/form'u çalıştırdı ilgili id'de.  Yeni bişey çalıştırmadı. form içinde notice var
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to message_url(@message), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@message),
          turbo_stream.update("sayi_revize", Message.count),
          turbo_stream.update('notice1', "Message #{Message.count+1} deleted" )
        ]
     end
      #bu satır sayesinde sayfanın tamamını refresh etmeden silmiş olduk ilgili id'yi.  

      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:body)
    end
end
