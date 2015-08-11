module AdminPanel::CommentHelper
  def audit_link_text(object)
    object.need_audit? ? t('button.audit') : t('button.preview')
  end

  def audit_link_class(object)
    object.need_audit? ? 'btn-warning' : 'btn-primary'
  end

  def comment_audit_link_button(object)
    return '' if object.content.blank?
    link_to audit_link_text(object), preview_admin_panel_comment_path(object), class: "btn #{audit_link_class(object)} btn-xs btn-sm various fancybox.ajax"
  end

  def review_audit_link_button(object)
    return '' if object.note.blank?
    link_to audit_link_text(object), preview_admin_panel_review_path(object), class: "btn #{audit_link_class(object)} btn-xs btn-sm various fancybox.ajax"
  end
end
