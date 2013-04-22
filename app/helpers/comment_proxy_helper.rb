module CommentProxyHelper

  def comment_proxy
    Struct.new(:id, :dom_id, :user, :created_at, :updated_at, :body_id, :body_html)
  end

  def proxy_as_comment(owner, attrs)
    attrs.reverse_merge! default_attrs_from_owner(owner)
    comment_proxy.new *attrs.values_at(:id, :dom_id, :user, :created_at, :updated_at, :body_id, :body_html)
  end

  def default_attrs_from_owner(owner)
    created_at = owner.created_at if owner.respond_to?(:created_at)
    updated_at = owner.updated_at if owner.respond_to?(:updated_at)
    { id: owner.id,
      dom_id: dom_id(owner),
      user: nil,
      created_at: created_at,
      updated_at: updated_at,
      body_id: 0,
      body_html: ""
    }
  end

end
