cluster1 = [1, 0, 0; 0.98, 0, 0.02; 0.97, 0, 0.03];
cluster2 = [0, 0.3, 0.3; 0.01, 0.4, 0.35; 0.04, 0.34, 0.45];
mix = [0.01, 0.32, 0.35; 0.01, 0.4, 0.31; 0.89, 0.2, 0.1];
sbagliato = [0.2, 0.2, 0.25; -0.1, -0.3, 0.4];

scores = [cluster1;cluster2;mix; sbagliato];
[cluster_id, centres_coordinates] = kmeans(scores,2);

centres_coordinates

figure
silhouette(scores,cluster_id)

scores = [cluster1;cluster2;mix];
cluster_id = kmeans(scores,2);

figure
silhouette(scores,cluster_id)