// Import necessary modules and dependencies
const UserService = require('../services/user.services');
const generater = require('../utils/generateToken');
const decoder = require('../utils/decodeToken');
const User = require('../model/user.model');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
require('dotenv').config();

const Post = require('../model/post.model');

const extractAndDecodeToken = async (req) => {
    const token = req.headers.authorization.split(' ')[1];
  
    if (!token) {
      throw new Error('Authorization fail!');
    }
  
    try {
      const decoded = await decoder.decodeToken(token);
      return decoded;
    } catch (err) {
      if (err instanceof jwt.TokenExpiredError) {
        throw new Error('Token expired!');
      } else {
        throw new Error('Invalid token!');
      }
    }
};

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

exports.getPosts = async (req, res) => {
try {
    const posts = await Post.find();
    res.status(200).json(posts);
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
    const currentUserId = currentUser.data._id;
    const { postId } = req.body;

    if (!postId) {
    return res.status(400).json({ error: 'Post ID is required.' });
    }

    const post = await Post.findOneAndDelete({ _id: postId, userId: currentUserId });

    if (!post) {
    return res.status(404).json({ error: 'Post not found or you do not have permission to delete this post.' });
    }

    res.status(200).json({ message: 'Post deleted successfully.' });
} catch (error) {
    res.status(500).json({ error: 'Internal server error.' });
}
};