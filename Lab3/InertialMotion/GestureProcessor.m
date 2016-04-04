//
//  GestureProcessor.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/15/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "GestureProcessor.h"
#import "AppDelegate.h"
#import "Geometry.h"

#define N_FEATURES_PER_ZONE 3
#define N_ZONES 9


// training.py output goes here:
#define N_LABELS 26
#define N_FEATURES (N_ZONES*N_FEATURES_PER_ZONE+1)
static const double weights[N_LABELS][N_FEATURES] = {
    {-0.74108, -1.02462, -2.88172, -1.69051, -3.56118, +1.34231, -0.92578, -0.57966, +0.63714, +2.71334, +4.51458, -4.11689, +1.28166, +2.90085, -0.43486, -0.74032, +0.13932, +0.40440, -0.17267, +0.88317, -6.29923, +1.15181, +0.13575, -3.13538, +0.26457, -0.20826, +0.23805, +1.03367},
    {-1.11857, +0.75754, -1.22522, -1.35951, +1.17894, +2.66473, -0.84371, -0.86603, -0.39638, +8.73403, -0.92201, -1.88663, +3.31323, +4.57872, +1.58266, -0.07299, +0.62798, +0.03363, -6.14470, -4.96724, +4.31397, -1.81650, -4.13799, +0.49043, -0.95606, -0.88729, -1.13181, -0.14671},
    {+0.24159, -5.80943, +3.90865, +0.94349, -1.44867, +2.36592, -0.20158, +1.06221, +2.56111, -3.95600, +0.54944, +1.10817, -1.74956, -3.83533, +2.83248, -2.07396, -1.34263, +4.98068, +1.65111, +3.21203, +0.35708, +1.94341, +0.52987, -2.52930, +3.17515, +2.62747, -2.53692, -0.03120},
    {+2.76869, +5.32739, -1.63247, -2.70301, +1.90766, +0.68756, -0.15111, +0.46190, +1.33875, -4.97368, +0.01271, +1.91109, -3.80897, -3.28747, +0.99640, -1.26234, -0.91149, +1.79764, +7.64865, -2.80066, -0.25529, +0.76692, -4.97965, +4.96798, -0.51892, -0.34315, -0.63944, -2.26733},
    {-0.13793, -1.61065, +1.33599, -2.29126, -0.30685, +2.92692, -0.79204, +0.20259, +2.39480, +5.67829, -3.86032, +2.81805, +4.19475, +4.17593, +0.41344, +0.47860, +0.40003, +2.17208, -4.46165, +3.34453, +5.52814, -3.74671, +4.68726, +0.07750, -0.51570, +2.78993, -2.62240, -1.69478},
    {+2.88527, -1.92328, -1.65861, -0.26182, -0.65890, +1.60420, +0.86296, +1.17316, +1.77777, +0.90276, +2.98282, +0.42813, +0.34065, +3.73034, -1.24299, +0.70165, +0.53504, +0.54795, -1.51237, -0.04642, +0.52247, -1.57010, -1.13895, -1.80054, -0.78506, -0.59698, -0.65509, +1.48279},
    {-1.16240, +2.05939, -4.53967, -1.25674, +2.21855, -0.79649, -0.09904, +0.28808, +0.66404, -1.93233, -1.21064, -4.68243, +0.56646, -0.56432, -2.21426, +3.21087, +0.96000, -0.67486, -1.93562, -5.18689, -1.87088, +2.55748, -1.91692, +0.27610, +0.56996, -0.60099, +0.80908, +0.45741},
    {-3.41047, +1.61327, -0.28829, +0.06712, -2.48560, +0.03441, -2.43124, -1.20199, +1.25246, +0.35917, +3.93335, -0.50305, +3.10818, +4.01697, +1.91406, -0.04506, -0.41578, +0.19695, +2.45378, +2.67983, +2.82256, +0.88242, -0.46031, +1.85248, -0.46631, -0.47422, -0.46879, +0.44122},
    {+1.30764, -1.07547, +2.52653, -1.38185, -0.24389, +0.81765, -1.34447, -0.46247, +1.09248, -0.24710, -1.50732, +0.99830, -1.25914, -0.56845, -0.59950, -0.15651, -0.21941, +0.34999, +6.37704, -3.23299, +1.77384, -2.73597, -2.43869, -0.61460, -0.40060, -0.49686, -0.07434, +0.02280},
    {-3.93234, -1.19972, +0.46726, +2.09006, -0.88110, +3.70829, -0.65644, +0.66321, +1.46042, -1.85775, -0.68026, -0.09013, -0.09708, -1.93237, +0.73645, +0.07630, -0.44020, +1.03887, +3.86987, -3.26253, -2.46149, +2.04130, -3.14102, +3.09860, -0.50165, -0.48315, -0.24858, +1.05106},
    {-2.43331, -1.57664, +1.34753, +0.29037, +0.69256, +1.01967, +1.77962, +1.26618, +0.78814, +3.68646, -0.01825, +2.02424, -1.56108, -1.19925, -0.52941, -0.21089, -0.50366, +1.05979, +0.25279, -0.13403, +0.10153, -0.78603, +4.55385, +4.45130, -0.90340, -1.10153, -0.15891, -0.05196},
    {-1.18898, +1.34823, +2.60386, -4.98431, +1.00577, +0.71661, -3.11526, +0.07648, +2.12993, -0.44127, +1.17764, +2.40165, -2.41681, -0.85507, +1.18049, -0.66618, -0.58847, +0.62234, +4.77437, +2.98741, +1.46991, +2.38910, +3.19476, -0.26560, +4.93218, +3.42002, +0.67190, -0.75281},
    {+3.02668, +1.74217, -3.35889, +0.61517, +0.52879, -2.04807, -1.03262, -0.30660, +1.54443, -0.52834, +0.98878, -3.65777, +0.45340, +0.08220, +0.78153, -0.12552, -0.14234, +1.55721, -0.65951, +3.14554, -0.54295, -1.11472, -0.39489, +2.59067, -0.17175, +0.37745, +3.81397, +0.60900},
    {+2.82736, -2.15734, -10.23795, +11.11301, -9.64781, -4.10934, +0.53136, +5.53207, -8.19287, +0.53312, +5.32155, -5.24640, -2.42504, -1.80712, -3.82789, -5.54131, +4.72560, -0.92036, -5.67539, +3.08256, -0.51291, -0.74516, +0.82766, +1.14269, +0.34898, -7.07720, -8.22185, +0.81849},
    {+9.92469, -4.77161, +5.10656, -12.59932, -0.86068, -5.00755, -0.01014, -10.67396, +2.26479, -1.43983, -3.09586, +1.40840, -3.95978, -0.13266, -2.85604, +6.01442, -3.75752, -9.79458, +1.52252, -6.29629, -4.31806, -1.43512, +5.39253, -6.14796, +0.30529, +3.53786, -2.00018, -1.61726},
    {+2.62279, +2.33436, -4.17555, +0.13740, +2.58176, +0.36707, -0.49857, -0.11294, +0.12414, +1.99962, -2.32895, -1.16118, -0.85195, -4.15749, -0.20797, -0.32046, -0.26590, -0.20654, +2.66499, -2.11134, -0.55135, -4.11331, +0.21598, -4.37452, -1.54571, -0.92125, -0.72276, +0.23285},
    {-3.30969, -3.99171, +2.36757, -0.16075, -4.23290, -2.59462, -2.13670, +0.41687, -2.04507, -2.50197, -0.58628, -1.18181, +5.27566, +0.93824, +2.16731, +1.29003, -0.33944, -2.21404, -3.24297, +3.01482, -1.51055, +4.44251, +5.11484, +2.74113, -0.22030, +4.52754, +8.31706, -0.33227},
    {-1.45778, +2.63124, -4.02218, -1.98646, +2.40979, +4.95028, -2.13457, -1.40283, +1.35178, +4.01648, -2.93805, -0.18970, +0.99940, +1.72911, +1.63516, -0.84063, -1.32210, +0.66310, -1.89095, +2.95895, -0.60773, +1.30044, +2.38387, +3.40854, +0.95443, +0.07892, +3.71982, -1.05187},
    {+1.97048, -3.54245, +1.49574, -0.26591, -4.16419, +0.75051, -0.06646, -1.61120, +0.06675, -0.84791, -1.12140, -0.96569, +0.06622, +1.29560, +2.03066, +0.84790, +0.68020, +1.51152, +0.16071, -3.48031, -2.21524, -0.63227, -3.56157, +0.01874, +0.77955, -0.15050, +1.37065, +1.83645},
    {+3.09633, +0.72751, +0.07719, +3.90537, +2.49171, +2.19743, +5.50901, +1.44016, +2.61571, -3.58137, -0.20626, +1.37126, -1.63016, -0.89057, +1.28206, -0.69815, -1.29373, +2.19595, -3.81502, -0.28628, +0.76934, -1.04394, -0.78970, +1.44595, -0.32992, -1.36476, +0.90325, +1.42769},
    {-0.86286, +4.16372, +4.43452, +1.55943, +3.12485, -2.41147, -0.19491, -3.81881, -3.74143, -3.68556, -4.99694, +1.85912, +0.86965, +2.16352, -0.20630, +0.36726, +1.51186, -0.11462, -0.80457, +12.02076, +5.13113, +1.90009, +1.72898, +0.29009, -1.75510, -2.82609, +4.66440, -2.46248},
    {-0.58878, +2.58236, +2.77333, +1.30119, +6.86018, -4.40321, +8.09399, +5.69888, -2.35891, -1.67862, +6.02965, +2.15182, -4.00153, +0.41584, -5.45787, -0.19576, -0.13749, -1.31537, -1.17039, +0.01953, +1.24654, -2.63741, -4.17277, -5.66459, -0.48243, -0.56209, -0.58855, -1.46468},
    {-3.64491, -2.23500, +0.52990, +1.77893, +3.78511, -3.08443, -0.58032, +2.62142, -8.70929, +0.99108, +2.15100, -1.03998, +4.12680, -0.89155, -1.53234, +0.83744, +3.07380, -1.77020, -2.38055, +7.21910, -0.19823, -0.31283, -1.47384, +2.93807, -1.10450, +0.04257, -2.28032, -0.45828},
    {-5.05080, -2.76733, -1.70132, -0.68291, -3.81115, -2.51510, +0.66810, -0.34629, -1.06573, -1.49039, -1.13791, +0.71059, +1.36480, +1.07787, -0.31998, -0.02291, -1.33236, -3.09993, +3.76611, -8.59586, -2.04121, +4.31685, +0.77801, -2.60422, -0.34894, -0.71494, -2.49858, +2.52425},
    {-0.82160, +4.89439, +5.91971, +5.95923, +0.14411, +0.03502, -1.52686, +0.32632, +0.74935, +1.00389, +0.23841, +3.72541, -1.25420, -5.40837, +1.92393, -0.47572, -0.86830, +1.06727, -0.74624, -3.89932, +0.58493, -1.15084, -4.58863, -0.90262, -1.07684, -1.88170, +0.33609, -0.01587},
    {-0.61216, +3.40454, +0.64922, +1.61272, +3.21862, +0.97707, +1.42802, +0.22521, +1.62577, -1.38280, -3.30825, +1.92342, -1.00337, -1.44834, -0.04559, -0.23512, +1.18655, +0.10498, -0.25260, -0.29078, -1.06964, +0.11209, +3.46924, -1.68643, +0.90005, +3.28777, +0.04251, +0.50272}
};
static NSString *const labels[N_LABELS+1] = {@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"?"};
// end of output of training.py


@implementation GestureProcessor

- (void)processGesture2DWithSamples:(const Sample2D *)samples
                              count:(NSUInteger)count
                            minSize:(double)minSize {
    // -- TASK 1A --
    double size, clippedSize;
    Sample2D rescaledSamples[count];
    double minX = +INFINITY, maxX = -INFINITY, minY = +INFINITY, maxY = -INFINITY;
    double totalT;
    // Compute size, clippedSize
    // Rescale points to lie in [0,1] x [0,1]
    for (int i = 0; i < count; i++) {
        double x = samples[i].x;
        double y = samples[i].y;
        minX = MIN(x, minX);
        minY = MIN(y, minY);
        maxX = MAX(x, maxX);
        maxY = MAX(y, maxY);
    }

    size = MAX(maxX - minX, maxY - minY);
    clippedSize = MAX(size, minSize);

    for (int i = 0; i < count; i++) {
        rescaledSamples[i].x = (samples[i].x - minX) / clippedSize;
        rescaledSamples[i].y = (samples[i].y - minY) / clippedSize;
        rescaledSamples[i].t = samples[i].t;
    }

    // -- TASK 1B --
    double features[N_FEATURES] = {};
    // Classify each point according to which zone of a 3x3 Tic-Tac-Toe board it would fall in
    // Compute the time spent in each zone and the distance traveled horizontally and vertically

    // Initialize features vector to 0, except set the last value to 1.0.
    memset(features, 0, sizeof(features));
    features[N_FEATURES - 1] = 1.0;

    double totalTime = rescaledSamples[count - 1].t - rescaledSamples[0].t;
    for (int i = 1; i < count; i++) {
        double midX = (rescaledSamples[i].x + rescaledSamples[i - 1].x) / 2;
        double midY = (rescaledSamples[i].y + rescaledSamples[i - 1].y) / 2;
        
        // We define nine zones (0-8) in a 3x3 drawing area, with the top left
        // as zone 0 and bottom right as zone 8. We can find the zone of the
        // current line segment simply by transforming the midpoint to a
        // coordinate pair on the 3x3 grid and calculating the zone number as
        // the sum of the x-coordinate and three times the y-coordinate.
        int xZone = (midX < 1.0) ? (int) (midX * 3) : 2;
        int yZone = (midY < 1.0) ? (int) (midY * 3) : 2;
        int zone = xZone + (3 * yZone);

        features[zone * N_FEATURES_PER_ZONE] += (rescaledSamples[i].t - rescaledSamples[i - 1].t) / totalTime;
        features[(zone * N_FEATURES_PER_ZONE) + 1] += rescaledSamples[i].x - rescaledSamples[i - 1].x;
        features[(zone * N_FEATURES_PER_ZONE) + 2] += rescaledSamples[i].y - rescaledSamples[i - 1].y;
    }

    // -- TASK 1C --
#if TRAINING
    // Use this code if you want to do additional training
    // Log feature vector (with empty string for label) for training
    // Make sure to fill in the empty label when you copy the output into training.py

    NSMutableString *s = [@"('', [" mutableCopy];
    for (int i=0; i<N_FEATURES; i++)
        [s appendFormat:@"%+.5f, ", features[i]];
    [s replaceCharactersInRange:NSMakeRange([s length]-2, 2) withString:@""];
    [s appendString:@", 1.0]),\n"];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate appendTrainingLog:s];
#endif
    // -- TASK 1D --
    // The output of the training procedure goes at the top of GestureProcessor.m.
    
    // -- TASK 1E --
    int best_label = N_LABELS;
    double best_score = -INFINITY;

    // Dot product with gesture templates in weights[][]
    for (int i = 0; i < N_LABELS; i++) {
        double score = 0;
        for (int j = 0; j < N_FEATURES; j++) {
            score += features[j] * weights[i][j];
        }
        if (score > best_score) {
            best_score = score;
            best_label = i;
        }
    }

#if !TRAINING
    // Report strongest match
    NSLog(@"Matched '%@' (score %+.5f)", labels[best_label], best_score);
#endif
    [self.delegate gestureProcessor:self didRecognizeGesture:labels[best_label]];
}

- (void)processGesture3DWithSamples:(const Sample3D *)samples
                              count:(NSUInteger)count
                            minSize:(double)minSize {
    Sample2D samples2D[count];
    
    // -- TASK 3A --
    // Estimate left-right, up-down axes by averaging orientation over time:
    GLKMatrix3 M = {};

    // For each i, convert samples[i].attitude to a 3x3 matrix and sum it into M.
    // Then find the rotation matrix most similar to the resulting sum.
    for (int i = 0; i < count; i++) {
        M = GLKMatrix3Add(M, GLKMatrix3MakeWithQuaternion(samples[i].attitude));
    }

    double scale = 1.0/count;
    GLKMatrix3 averagingMatrix = GLKMatrix3Make(scale, 0, 0,
                                                0, scale, 0,
                                                0, 0, scale);
    M = NearestRotation(GLKMatrix3Multiply(M, averagingMatrix));

    // -- TASK 3B --
    // Project points to 2D:
    // For each i, form the matrix-vector product of M with samples[i].location
    // and copy the transformed x and y coordinates, along with the timestamp,
    // to samples2D[i].
    for (int i = 0; i < count; i++) {
        GLKVector3 transform = GLKMatrix3MultiplyVector3(M, samples[i].location);
        samples2D[i].x = transform.x;
        samples2D[i].y = transform.y;
        samples2D[i].t = samples[i].t;
    }

    // Apply 2-D solution
    [self processGesture2DWithSamples:samples2D count:count minSize:minSize];
}

@end
