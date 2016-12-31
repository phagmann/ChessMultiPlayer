class PiecesController < ApplicationController
  before_action :authenticate_player!

  def select
    @piece = Piece.find(params[:id])
    if @piece.player_id == current_player.id && @piece.player_id == @piece.game.turn
      if @piece.selected != true then @piece.selected = true else @piece.selected = false end

      old_selected_piece = @piece.game.pieces.find_by(selected: true) || 0
      if old_selected_piece != 0
        old_selected_piece.selected = false
        old_selected_piece.update_attributes(selected: old_selected_piece.selected)
      end
      @piece.update_attributes(selected: @piece.selected)
      render json: @piece

      update_firebase(pieceId: @piece.id,
                      timeStamp: Time.now)
    end

    # redirect_to game_path(@piece.game_id)
  end

  def update
    @piece = Piece.find(params[:id])
    row = params[:y_position]
    cell = params[:x_position]
    @board = @piece.game.pieces_as_array
    @piece.move_to!(row, cell) if @piece.piece_can_move_to(@board).include?([row.to_i, cell.to_i])
    render json: @piece
    update_firebase(pieceId: @piece.id,
                    y_position: row,
                    x_position: cell,
                    timeStamp: Time.now) 

    # redirect_to game_path(@piece.game_id)
  end


  private

  def piece_params
    params.require(:piece).permit(:selected, :x_position, :y_position, :captured_piece)
  end

  def update_firebase(data)
    base_uri = 'https://ruby-knights.firebaseio.com'
    firebase = Firebase::Client.new(base_uri)
    response = firebase.set("#{@piece.id}", data)
  end

end

# base_uri = 'https://ruby-knights.firebaseio.com'
# firebase = Firebase::Client.new(base_uri)
# response = firebase.set("#{@piece.id}", :created => Firebase::ServerValue::TIMESTAMP)
