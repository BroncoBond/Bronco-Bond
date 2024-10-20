const router = require('express').Router();
const postController = require('../controller/post.controller');
const protectRouter = require('../middleware/protectRouter');

// Create Post
router.post('/create', protectRouter.protectRoute, postController.createPost);

// Get all Posts
router.get('/', protectRouter.protectRoute, postController.getPosts);

// Update Post
router.put('/update/:id', protectRouter.protectRoute, postController.updatePost);

// Delete Post
router.delete('/delete/:id', protectRouter.protectRoute, postController.deletePost);

module.exports = router;