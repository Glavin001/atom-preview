class PostsController extends Ember.ArrayController
  trimmedPosts: ~>
    @content.slice(0, 3)
