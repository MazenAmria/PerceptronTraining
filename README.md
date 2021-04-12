# Perceptron-Training-MIPS
Training algorithm for single layer neural network using MIPS assembly language.

The program uses linear algebra (matrices, vectors and thier operations) to implement the training algorithm.

## Transform
First we have the transform algorithm, which is used to transform the input vector (feature vector) into the output vector (classes vector) using the weights matrix as the change of bases matrix and then applying the activation function on the output vector. (i.e. predicts the classes given the features).

Starting by calculating the weighted sum of the neurons (by linearly transforming the feature vector with the weigths matrix and then subtracting the threshlods).

![transform1](/figures/transform1.png)

Then we can apply the chosen activation function to the weighted sum in order to get the output of the transformation. The program allows you to define your own activation function as a function and then reference it with the training model and it'll be used for this stage. Also applying the activation function on the whole vector allowed us to implement both single neuron and multi neuron activation functions. In the perceptron module you'll find two built-in activation functions, one is the hard limitter which is a single neuron activation function that returns 1 when the weighted sum is positive and 0 otherwise, and the other is the maximum weighted sum which is a multi neuron activation function that returns 1 for the neuron with maximum weghted sum and 0 for the other neurons.

![transform2](/figures/transform2.png)
