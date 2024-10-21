const Post = require('../model/post.model');

// Used for functions that require administrative permissions
const User = require('../model/user.model');
const userController = require('../controller/user.controller');

exports.createPost = async (req, res) => {
try {
    const currentUser = await extractAndDecodeToken(req);
    const currentUserId = currentUser.data._id;
    
    const { title, content } = req.body;

    if (!title || !content) {
    return res.status(400).json({ error: 'Title and content are required.' });
    }

    const newPost = new Post({
    userId: currentUserId,
    title,
    content,
    });

    await newPost.save();
    res.status(201).json(newPost);
} catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
}
};

exports.updatePost = async (req, res) => {
try {
    const currentUser = await extractAndDecodeToken(req);
    const currentUserId = currentUser.data._id;
    const { postId, title, content } = req.body;

    if (!postId || !title || !content) {
    return res.status(400).json({ error: 'Post ID, title, and content are required.' });
    }

    const post = await Post.findOneAndUpdate(
    { _id: postId, userId: currentUserId },
    { title, content },
    { new: true }
    );

    if (!post) {
    return res.status(404).json({ error: 'Post not found or you do not have permission to update this post.' });
    }

    res.status(200).json(post);
} catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
}
};

exports.deletePost = async (req, res) => {
  try {
      const currentUser = await extractAndDecodeToken(req);
      const tokenUserId = currentUser.data._id;
      const tokenUser = await User.findById(tokenUserId); //TODO - check tokenUser usage

      const postId = req.body._id; // Corrected variable name

      if (!postId) {
          return res.status(400).json({ error: 'Post ID is required.' });
      }

      const post = await Post.findOneAndDelete({ _id: postId, userId: tokenUserId }); // Corrected variable name

      if (!post) {
          return res.status(404).json({ error: 'Post not found or you do not have permission to delete this post.' });
      }

      res.status(200).json({ message: 'Post deleted successfully.' });
  } catch (error) {
      res.status(500).json({ error: 'Internal server error.' });
  }
};

exports.likePost = async (req, res) => {
  try {
    const currentUser = await extractAndDecodeToken(req);
    const userId = currentUser.data._id;
    const postId = req.params.id;

    if (!postId) {
      return res.status(400).json({ error: 'Post ID is required.' });
    }

    const post = await Post.findById(postId);

    if (!post) {
      return res.status(404).json({ error: 'Post not found.' });
    }

    const isLiked = post.likes.includes(userId);

    if (isLiked) {
      // Unlike the post
      post.likes = post.likes.filter(id => id.toString() !== userId.toString());
    } else {
      // Like the post
      post.likes.push(userId);
    }

    await post.save();

    res.status(200).json({ message: isLiked ? 'Post unliked successfully.' : 'Post liked successfully.' });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
  }
};

exports.savePost = async (req, res) => {
  try {
    const currentUser = await extractAndDecodeToken(req);
    const userId = currentUser.data._id;
    const postId = req.params.id;

    if (!postId) {
      return res.status(400).json({ error: 'Post ID is required.' });
    }

    const post = await Post.findById(postId);

    if (!post) {
      return res.status(404).json({ error: 'Post not found.' });
    }

    const isSaved = post.savedBy.includes(userId);

    if (isSaved) {
      // Unsave the post
      post.savedBy = post.savedBy.filter(id => id.toString() !== userId.toString());
    } else {
      // Save the post
      post.savedBy.push(userId);
    }

    await post.save();

    res.status(200).json({ message: isSaved ? 'Post unsaved successfully.' : 'Post saved successfully.' });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
  }
};

exports.setPostStatus = async (req, res) => {
  try {
    const currentUser = await extractAndDecodeToken(req);
    const userId = currentUser.data._id;
    const postId = req.params.id;
    const { status } = req.body;

    if (!postId) {
      return res.status(400).json({ error: 'Post ID is required.' });
    }

    if (!status) {
      return res.status(400).json({ error: 'Status is required.' });
    }

    const post = await Post.findOne({ _id: postId, userId });

    if (!post) {
      return res.status(404).json({ error: 'Post not found or you do not have permission to update this post.' });
    }

    post.status = status;
    await post.save();

    res.status(200).json({ message: 'Post status updated successfully.' });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
  }
};

exports.setPostVisibility = async (req, res) => {
  try {
    const currentUser = await extractAndDecodeToken(req);
    const userId = currentUser.data._id;
    const postId = req.params.id;
    const { visibility } = req.body;

    if (!postId) {
      return res.status(400).json({ error: 'Post ID is required.' });
    }

    if (!visibility) {
      return res.status(400).json({ error: 'Visibility is required.' });
    }

    const post = await Post.findOne({ _id: postId, userId });

    if (!post) {
      return res.status(404).json({ error: 'Post not found or you do not have permission to update this post.' });
    }

    post.visibility = visibility;
    await post.save();

    res.status(200).json({ message: 'Post visibility updated successfully.' });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
  }
};

// Forum Page - Get All Posts
exports.getPosts = async (req, res) => {
  try {
    const currentUser = await extractAndDecodeToken(req);
    const userId = currentUser.data._id;
    const user = await User.findById(userId).populate('friends');

    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    // Find posts by the user and their friends
    const friendIds = user.friends.map(friend => friend._id);
    const posts = await Post.find({
      author: { $in: [userId, ...friendIds] }
    }).sort({ timestamp: -1 }); // Sort by timestamp in descending order - newest first

    res.status(200).json(posts);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
  }
};