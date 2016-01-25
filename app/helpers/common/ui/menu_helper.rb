#
# Helper methods for drawing the top navigation menus
#
# Available to all views
#
module Common::Ui::MenuHelper

  def split_entities_into_columns(entities)
    entities.sort! {|a,b| a.name <=> b.name}
    cols = {}
    if entities.size > 3
      half = entities.size/2.round
      cols[:right_col] = entities.slice!(-half, half)
      cols[:left_col] = entities
    else
      cols[:left_col] = entities
      cols[:right_col] = []
    end
    return cols
  end

end
