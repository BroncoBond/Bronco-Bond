const router = require('express').Router();
const postController = require('../controller/post.controller');
const protectRouter = require('../middleware/protectRouter');

// Create Post
router.post('/create', protectRouter.protectRoute, postController.createPost);

// Update Post
router.put('/update/:id', protectRouter.protectRoute, postController.updatePost);

// Delete Post
router.delete('/delete/:id', protectRouter.protectRoute, postController.deletePost);

// Like or Unlike Post
router.post('/like/:id', protectRouter.protectRoute, postController.likePost);

// Save or Unsave Post
router.post('/save/:id', protectRouter.protectRoute, postController.savePost);

// Set Post Status (Draft/Published)
router.put('/status/:id', protectRouter.protectRoute, postController.setPostStatus);

// Set Post Visibility (Private/Friends/Public)
router.put('/visibility/:id', protectRouter.protectRoute, postController.setPostVisibility);

// See All Posts on Forum Page
router.get('/', protectRouter.protectRoute, postController.getPosts);

/*
Features to Implement:
- Comments (check comment.model.js)
- Attachments and Media
- Share Link
- Impressions
- See All Likes, Comments, and Saves 
- Search Post (by ID or shareable link)
- Filter Posts (by status or visibility)
- And More... 
*/
module.exports = router;