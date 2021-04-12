# Perceptron Training using MIPS
Training algorithm for single layer neural network using MIPS assembly language.

The program uses linear algebra (matrices, vectors and thier operations) to implement the training algorithm.

Symbols:
* X: Input
* W: Weight
* T: Threshold
* S: Weighted Sum
* Y: Output
* Yd: Desired Output
* δ: Error
* p: Iteration
* ΔW: Needed Change in Weight
* ΔT: Needed Change in Threshold
* β: Momentum
* α: Learning Rate

## Transform
First we have the transform algorithm, which is used to transform the input vector (feature vector) into the output vector (classes vector) using the weights matrix as the change of bases matrix and then applying the activation function on the output vector. (i.e. predicts the classes given the features).

Starting by calculating the weighted sum of the neurons (by linearly transforming the feature vector with the weigths matrix and then subtracting the threshlods).

![transform1](/figures/transform1.png)

Then we can apply the chosen activation function to the weighted sum in order to get the output of the transformation. The program allows you to define your own activation function as a function and then reference it with the training model and it'll be used for this stage. Also applying the activation function on the whole vector allowed us to implement both single neuron and multi neuron activation functions. In the perceptron module you'll find two built-in activation functions, one is the hard limitter which is a single neuron activation function that returns 1 when the weighted sum is positive and 0 otherwise, and the other is the maximum weighted sum which is a multi neuron activation function that returns 1 for the neuron with maximum weghted sum and 0 for the other neurons.

![transform2](/figures/transform2.png)

## Fit
In this part the weights matrix and the threshlods vector will be modified to reduce the error in the prediction. It iterates over the dataset, and in each iteration it will do the following for the corresponding data tuple:
* Transforms the feature vector using the existing model.
* Calculating the error between the desired output and the given output.

![fit1](/figures/fit1.png)

* Calculating the needed change in the weights and the needed change in the thresholds.

![fit2](/figures/fit2.png)
![fit3](/figures/fit3.png)

* Applying the Changes

![fit4](/figures/fit4.png)
![fit5](/figures/fit5.png)

The algorithm iterates over the entire dataset in one epoch, if more than one epoch are given it will re-iterate over the entire dataset as many epochs as the are.

## Program Modules
The program consists of three modules:
* `linalg_module` which contains all the functions needed to perform linear algebra operations. (Note: the function `vector_cross` has different definition than the original vector cross multiplication).
* `debug_module` which is used to debug a vector/matrix with a fancy output and a title message.
* `perceptron_module` which contains the `fit` and `transform` functions and the built-in activation functions.

Using these modules requires some predefined variables in `.data` section, refer `.data` section in `perceptron_module_test.s` for usage example.

The program starts by asking the user for some values and the input file. Refer `sample_input` and `sample_output` for some examples of I/O interaction with the program.

## Note
We uses some basic conventions that the GCC compiler uses when compiling to MIPS assembly:
* Call stack and Frames by making use of the $fp and $sp registers.
* Local variables, passed arguments (that doesn't fit in $ax registers), returned values (that doesn't fit in $v registers) are stored in the frame of the function.
* The architecture of for loops, if statements and nesting them.

Some of the comments contain the equivalent C code of the written MIPS assembly.

Each module has it's own testcase that covers the basic functionality of the module. Refer to the bash scripts to generate the `main.s` file that contains that testcase.
