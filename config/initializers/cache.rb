## always cache avatar and theme controllers
ThemeController.perform_caching = true
AvatarsController.perform_caching = true
Me::AvatarsController.perform_caching = true
Groups::AvatarsController.perform_caching = true
